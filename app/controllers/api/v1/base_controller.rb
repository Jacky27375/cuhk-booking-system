module Api
  module V1
    class BaseController < ActionController::API
      include ApiAuthenticatable

      rescue_from ActiveRecord::RecordNotFound do |e|
        render json: { error: "#{e.model} not found" }, status: :not_found
      end

      rescue_from ActiveRecord::RecordInvalid do |e|
        render json: { error: "Validation failed", details: e.record.errors.full_messages }, status: :unprocessable_entity
      end

      private

      def pagination_params
        page = [params.fetch(:page, 1).to_i, 1].max
        per_page = [[params.fetch(:per_page, 25).to_i, 1].max, 100].min
        { page: page, per_page: per_page }
      end

      def paginate(scope)
        paging = pagination_params
        offset = (paging[:page] - 1) * paging[:per_page]
        total = scope.count

        records = scope.limit(paging[:per_page]).offset(offset)
        {
          records: records,
          meta: {
            page: paging[:page],
            per_page: paging[:per_page],
            total: total,
            total_pages: (total.to_f / paging[:per_page]).ceil
          }
        }
      end
    end
  end
end
