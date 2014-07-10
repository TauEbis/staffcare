module LocationPlansHelper

  def action_links(location_plan)
    p = policy(location_plan)
    return unless p.change_state?

    p_class = case location_plan.approval_state
                when 'pending'
                  'btn-warning'
                when 'manager_approved'
                  'btn-info'
                when 'gm_approved'
                  'btn-success'
              end

    ((p.state_downgrade? ? down_action_link(location_plan) : '') + ' ' +
     (p.state_upgrade? ? up_action_link(location_plan) :   '') + ' ' +
     %{<a class="btn #{p_class} disabled">#{location_plan.approval_state.humanize}</a>}.html_safe
    ).html_safe
  end

  private

  # WARNING: Does NOT check schedule.active? or location_plan ownership!
  def down_action_link(location_plan)
    case location_plan.approval_state
      when 'manager_approved'
        text = current_user.manager? ? 'Downgrade to un-approved' : 'Force downgrade to un-approved'
        change_state_link(text, 'pending', 'btn-default', location_plan)
      when 'gm_approved'
        text = current_user.gm? ? 'Downgrade to manager-approved' : 'Force downgrade to manager-approved'
        change_state_link(text, 'manager_approved', 'btn-default', location_plan)
      else
        ''
    end
  end

  # WARNING: Does NOT check schedule.active? or location_plan ownership!
  def up_action_link(location_plan)
    case location_plan.approval_state
      when 'pending'
        text = current_user.manager? ? 'Approve' : 'Force to manager-approved'
        btn_class = current_user.manager? ? 'btn-success' : 'btn-default'
        change_state_link(text, 'manager_approved', btn_class, location_plan)
      when 'manager_approved'
        text = current_user.gm? ? 'Approve' : 'Force to gm-approved'
        btn_class = current_user.gm? ? 'btn-success' : 'btn-default'
        change_state_link(text, 'gm_approved', btn_class, location_plan)
      else
        ''
    end
  end

  def change_state_link(text, state, btn_class, location_plan)
    link_to text, change_state_location_plans_path(location_plan_ids: [location_plan], state: state), method: :post, class: "btn #{btn_class}"
  end

end
