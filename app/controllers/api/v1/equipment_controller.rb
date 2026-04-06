module Api
  module V1
    class EquipmentController < BaseController
      def index
        equipment = Equipment.visible_to_user(current_api_user).order(:name)
        result = paginate(equipment)

        render json: {
          equipment: result[:records].map { |e| equipment_json(e) },
          meta: result[:meta]
        }
      end

      def show
        equipment = Equipment.visible_to_user(current_api_user).find(params[:id])
        render json: { equipment: equipment_json(equipment) }
      end

      private

      def equipment_json(equipment)
        {
          id: equipment.id,
          name: equipment.name,
          total_quantity: equipment.quantity,
          available_quantity: equipment.available_quantity,
          tenant_id: equipment.tenant_id,
          created_at: equipment.created_at.iso8601,
          updated_at: equipment.updated_at.iso8601
        }
      end
    end
  end
end
