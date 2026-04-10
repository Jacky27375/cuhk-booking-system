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

    direction_label = if current_sort == column && current_direction.present?
      " (#{current_direction})"
    else
      ""
    end

    link_to "#{label}#{direction_label}".html_safe, params_hash
  end

  def nav_link(label, path, icon: "", controllers: [], actions: [])
    matches_controller = controllers.include?(controller_name)
    matches_action = actions.empty? || actions.include?(action_name)
    active = current_page?(path) || (matches_controller && matches_action)
    css = "sidebar-link#{active ? ' active' : ''}"
    link_to path, class: css do
      content_tag(:span, icon, class: "nav-icon") + content_tag(:span, label)
    end
  end

  def user_initials(user)
    return "?" unless user&.email.present?
    user.email[0..0].upcase
  end

  def status_badge(status)
    css = case status.to_s.downcase
    when "pending" then "badge-pending"
    when "approved" then "badge-approved"
    when "rejected" then "badge-rejected"
    when "cancelled" then "badge-cancelled"
    when "under_review" then "badge-under-review"
    when "borrowed" then "badge-borrowed"
    when "returned" then "badge-returned"
    else "badge-pending"
    end
    content_tag(:span, status.to_s.titleize, class: "badge #{css}")
  end
end
