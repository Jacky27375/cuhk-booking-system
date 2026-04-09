class VenuesController < ApplicationController
  before_action :set_venue, only: %i[show edit update destroy]
  before_action :require_admin_or_staff, only: %i[new create edit update destroy]
  before_action :ensure_tenant_present_for_manage!, only: %i[new create edit update destroy]
  before_action :redirect_root_staff_venue_creation_to_requests!, only: %i[new create]
  before_action :prepare_form_options, only: %i[new create edit update]

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
    @venue = Venue.new(scoped_venue_params)

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
    respond_to do |format|
      if @venue.update(scoped_venue_params)
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

    def ensure_tenant_present_for_manage!
      return if current_user.admin? || current_user.tenant.present?

      redirect_to venues_path, alert: "Your account is not linked to a tenant."
    end

    def redirect_root_staff_venue_creation_to_requests!
      return unless current_user&.root_staff_account?

      redirect_to new_venue_request_path, alert: "Root staff must submit a venue request to add new venues."
    end

    def prepare_form_options
      @departments = if current_user.admin?
        ["University", "Chung Chi College", "New Asia College", "United College", "Shaw College", "Morningside College", "S.H. Ho College", "CW Chu College", "Wu Yee Sun College", "Lee Woo Sing College"]
      else
        [current_user.tenant&.name].compact
      end
    end

    def scoped_venue_params
      attrs = venue_params.to_h
      return attrs if current_user.admin?

      attrs["tenant_id"] = current_user.tenant_id
      attrs["department"] = current_user.tenant.name
      attrs
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
