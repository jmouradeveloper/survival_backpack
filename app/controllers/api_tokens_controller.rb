class ApiTokensController < ApplicationController
  before_action :set_api_token, only: [:destroy]
  
  def index
    @api_tokens = current_user.api_tokens.order(created_at: :desc)
    @new_token = nil
  end

  def create
    @api_token = current_user.api_tokens.build(api_token_params)
    
    if @api_token.save
      # Store the raw token to display to user (only time they'll see it)
      @new_token = @api_token.raw_token
      @api_tokens = current_user.api_tokens.order(created_at: :desc)
      
      respond_to do |format|
        format.html { render :index, notice: "API token created successfully. Make sure to copy it now - you won't be able to see it again!" }
        format.turbo_stream
      end
    else
      @api_tokens = current_user.api_tokens.order(created_at: :desc)
      render :index, status: :unprocessable_entity
    end
  end

  def destroy
    @api_token.destroy
    redirect_to api_tokens_path, notice: "API token revoked successfully."
  end
  
  private
  
  def set_api_token
    @api_token = current_user.api_tokens.find(params[:id])
  end
  
  def api_token_params
    params.require(:api_token).permit(:name)
  end
end
