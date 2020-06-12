module Api
  module V1
    class PostsController < ApplicationController
      before_action :set_post, only: [:show, :update, :destroy]
      before_action :env_logging

      def index
        posts = Post.order(created_at: :desc)
        render json: { status: 'SUCCESS', message: 'Loaded posts', data: posts }
      end

      def show
        render json: { status: 'SUCCESS', message: 'Loaded the post', data: @post }
      end

      def create
        post = Post.new(post_params)
        if post.save
          render json: { status: 'SUCCESS', data: post }
        else
          render json: { status: 'ERROR', data: post.errors }
        end
      end

      def destroy
        @post.destroy
        render json: { status: 'SUCCESS', message: 'Deleted the post', data: @post }
      end

      def update
        if @post.update(post_params)
          render json: { status: 'SUCCESS', message: 'Updated the post', data: @post }
        else
          render json: { status: 'SUCCESS', message: 'Not updated', data: @post.errors }
        end
      end

      private

      def set_post
        @post = Post.find(params[:id])
      end

      def post_params
        params.require(:post).permit(:title)
      end

      def env_logging
        sender = ApplicationInsights::Channel::AsynchronousSender.new
        queue = ApplicationInsights::Channel::AsynchronousQueue.new sender
        channel = ApplicationInsights::Channel::TelemetryChannel.new nil, queue
        @tc = ApplicationInsights::TelemetryClient.new ENV['INSTRUMENTATION_KEY'], channel
        @tc.channel.queue.max_queue_length = 10
        @tc.channel.sender.send_buffer_size = 5
        @tc.channel.sender.send_time = 5
        @tc.channel.sender.send_interval = 0.5

        ENV.each do |e|
          Rails.logger.info("="*80)
          Rails.logger.info(e)
          @tc.track_trace "Trace ENV #{e[0]}=#{e[1]}", ApplicationInsights::Channel::Contracts::SeverityLevel::INFORMATION
        end
        request.env.each do |e|
          next if [
            "puma.config", 
            "action_dispatch.remote_ip", 
            "action_controller.instance",
            "action_dispatch.logger",
            "action_dispatch.backtrace_cleaner",
            "action_dispatch.key_generator"
          ].include?(e[0])
          Rails.logger.info("="*80)
          Rails.logger.info(e)
          @tc.track_trace "Trace Request ENV #{e[0]}=#{e[1]}", ApplicationInsights::Channel::Contracts::SeverityLevel::INFORMATION
        end
        @tc.flush
      end
    end
  end
end