module ApplicationHelper
  def sortable_header_link(label, column, current_sort:, current_direction:)
    next_direction = if current_sort != column
      "asc"
    elsif current_direction == "asc"
      "desc"
    else
      nil
    end

    next_sort = next_direction.present? ? column : nil
    params_hash = request.query_parameters.merge(sort: next_sort, direction: next_direction).compact

    suffix = if current_sort == column && current_direction.present?
      " (#{current_direction})"
    else
      ""
    end

    link_to "#{label}#{suffix}", params_hash
  end
end
