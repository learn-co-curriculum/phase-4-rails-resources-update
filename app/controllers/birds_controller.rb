class BirdsController < ApplicationController

  def increment_likes
    # find the bird we're trying to update
    bird = Bird.find_by(id: params[:id])
    # update the bird, use the number of current likes + 1 to determine the next number of likes
    bird.update(likes: bird.likes + 1)
    # send a response with the updated bird
    render json: bird
  end

  def update
    # find the bird we're trying to update
    bird = Bird.find_by(id: params[:id])
    # update the bird, using the data from the body
    bird.update(bird_params)
    # send a response with the updated bird
    render json: bird
  end

  # GET /birds
  def index
    birds = Bird.all
    render json: birds
  end

  # POST /birds
  def create
    bird = Bird.create(bird_params)
    render json: bird, status: :created
  end

  # GET /birds/:id
  def show
    bird = Bird.find_by(id: params[:id])
    if bird
      render json: bird
    else
      render json: { error: "Bird not found" }, status: :not_found
    end
  end

  private

  def bird_params
    params.permit(:name, :species, :likes)
  end

end
