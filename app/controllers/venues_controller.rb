class VenuesController < ApplicationController
  before_action :set_venue, only: %i[show edit update destroy]
  before_action :require_admin_or_staff, only: %i[new create edit update destroy]

  # GET /venues or /venues.json
  def index
    @venues = sort_venues(accessible_venues)
  end

  # GET /venues/1 or /venues/1.json
  def show
  end

  # GET /venues/new
  def new
    @venue = Venue.new
  end

  # GET /venues/1/edit
  def edit
  end

  # POST /venues or /venues.json
  def create
    @venue = Venue.new(venue_params)
    apply_staff_tenant_defaults

    respond_to do |format|
      if @venue.save
        format.html { redirect_to @venue, notice: "Venue was successfully created." }
        format.json { render :show, status: :created, location: @venue }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @venue.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /venues/1 or /venues/1.json
  def update
    apply_staff_tenant_defaults

    respond_to do |format|
      if @venue.update(venue_params)
        format.html { redirect_to @venue, notice: "Venue was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @venue }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @venue.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /venues/1 or /venues/1.json
  def destroy
    @venue.destroy!

    respond_to do |format|
      format.html { redirect_to venues_path, notice: "Venue was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_venue
      @venue = accessible_venues.find(params.expect(:id))
    rescue ActiveRecord::RecordNotFound
      redirect_to venues_path, alert: "You are not authorized to access this venue."
    end

    # Only allow a list of trusted parameters through.
    def venue_params
      permitted = [:name, :description, :department]
      if current_user.admin?
        permitted += [:tenant_id]
      end
      params.expect(venue: permitted)
    end

    def accessible_venues
      Venue.visible_to_user(current_user)
    end

    def apply_staff_tenant_defaults
      return if current_user.admin?

      @venue.tenant = current_user.tenant
    end

    def sort_venues(scope)
      allowed = %w[name description department]

      @sort_column = params[:sort]
      @sort_direction = params[:direction]

      unless allowed.include?(@sort_column) && %w[asc desc].include?(@sort_direction)
        @sort_column = nil
        @sort_direction = nil
        return scope.order(name: :asc)
      end

      direction = @sort_direction == "asc" ? :asc : :desc
      venues = Venue.arel_table
      order_expr = case @sort_column
      when "name"
        venues[:name]
      when "description"
        venues[:description]
      when "department"
        venues[:department]
      end

      scope.order(direction == :asc ? order_expr.asc : order_expr.desc)
    end
end
