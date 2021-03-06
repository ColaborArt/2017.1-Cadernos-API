class UsersController < ApplicationController
  skip_before_action :authenticate_request, only: [:create, :all]
  before_action :set_user, only: [:show, :update, :destroy, :books, :invites, :sent_invites, :memberships, :set_avatar]


  # GET /users
  def index
    @users = User.paginate(:page => params[:page], :per_page => params[:per_page] || 10).order('name ASC')
  end

  def all
    @users = User.all.order('id ASC')
    render :index
  end

  # GET /users/1
  def show
    @user
  end

  def books
    @books = @user.books.all
  end

  def invites
    @invites = @user.invitations.all
  end

  def sent_invites
    @invites = @user.sent_invites.all
  end

  def memberships
    @memberships = @user.memberships.all
  end

  # POST /users
  def create
    @user = User.new(user_params)

    if @user.save
      @token = AuthenticateUser.call(@user.email, @user.password)

      response.set_header("auth_token", @token.result)
      render :show, status: :created
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /users/1
  def update
    if @user.update(user_params)
      render json: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /users/1
  def destroy
    @user.destroy
    redirect_to action: 'index', status:200
  end

  def set_avatar
    @user.avatar_base = params[:avatar_base]
    @user.email_confirmation = params[:email]

    if @user.save
      render :show
    else
      render json: {success: false, errors: @user.errors}
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def user_params
      params.require(:user).permit(:name, :email, :email_confirmation, :password, :password_confirmation)
    end
end
