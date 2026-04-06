module Api
  module V1
    class VenuesController < BaseController
      def index
        venues = Venue.visible_to_user(current_api_user).order(:name)
        result = paginate(venues)

        render json: {
          venues: result[:records].map { |v| venue_json(v) },
          meta: result[:meta]
        }
      end

      def show
        venue = Venue.visible_to_user(current_api_user).find(params[:id])
        render json: { venue: venue_json(venue) }
      end

      private

      def venue_json(venue)
        {
          id: venue.id,
          name: venue.name,
          department: venue.department,
          description: venue.description,
          tenant_id: venue.tenant_id,
          created_at: venue.created_at.iso8601,
          updated_at: venue.updated_at.iso8601
        }
      end
    end
  end
end
