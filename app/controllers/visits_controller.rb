require 'yaml'
class VisitsController < ApplicationController
  def index
    @visits = Visit.all
  end
  # Show a visit
  #
  # GET /visits/:id
  def show
    @visit = Visit.find(params[:id])
  end

  # Show `new visit` form
  #
  # GET /visits/new
  def new
    @visit = Visit.new
  end

  # Show `edit visit` form
  #
  # GET /visits/edit
  def edit
    @visit = Visit.find(params[:id])
  end

  # Update visit
  #
  # PATCH /visit/:id
  def update
    @visit = Visit.find(params[:id])
    if @visit.update(visit_params)
      redirect_to @visit
    else
      render 'edit'
    end
  end

  # Create a new visit
  #
  # POST /visits
  def create
    @visit = Visit.new(visit_params)
    if @visit.save
      redirect_to @visit
    else
      render 'new'
    end
  end

  # Delete a visit
  #
  # DELETE /visits/:id
  def destroy
    @visit = Visit.find(params[:id])
    @visit.destroy

    redirect_to visits_path
  end

  private
  def visit_params
    params.require(:visit).permit(:name, :model, :date)
  end
end
