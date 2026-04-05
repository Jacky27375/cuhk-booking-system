class EquipmentsController < ApplicationController
  before_action :set_equipment, only: [:show, :edit, :update, :destroy]
  before_action :require_staff_or_admin, only: [:new, :create, :edit, :update, :destroy]
  before_action :ensure_tenant_present_for_manage!, only: [:new, :create]

  def index
    @equipments = tenant_equipments.order(:name)
  end

  def show
  end

  def new
    @equipment = current_user.tenant.equipment.new
  end

  def create
    @equipment = current_user.tenant.equipment.new(equipment_params)

    if @equipment.save
      redirect_to equipment_path(@equipment), notice: "Equipment created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @equipment.update(equipment_params)
      redirect_to equipment_path(@equipment), notice: "Equipment updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @equipment.destroy
    redirect_to equipments_path, notice: "Equipment deleted successfully."
  end

  def borrow_form
    @equipment = tenant_equipments.find(params[:id])
    @booking = EquipmentBooking.new
  end

  def borrow
    @equipment = tenant_equipments.find(params[:id])
    @booking = EquipmentBooking.new(
      equipment: @equipment,
      user: current_user,
      quantity: params[:booking][:quantity],
      start_date: params[:booking][:start_date],
      end_date: params[:booking][:end_date]
    )

    if @booking.save
      redirect_to equipment_path(@equipment), notice: "Equipment booking submitted"
    else
      render :borrow_form, status: :unprocessable_entity
    end
  end

  private

  def set_equipment
    @equipment = tenant_equipments.find(params[:id])
  end

  def tenant_equipments
    return Equipment.none unless current_user

    Equipment.visible_to_user(current_user)
  end

  def require_staff_or_admin
    return if current_user.admin? || current_user.staff?

    redirect_to equipments_path, alert: "You are not authorized to perform this action."
  end

  def ensure_tenant_present_for_manage!
    return if current_user.tenant.present?

    redirect_to equipments_path, alert: "Your account is not linked to a tenant."
  end

  def equipment_params
    params.require(:equipment).permit(:name, :quantity)
  end
end
