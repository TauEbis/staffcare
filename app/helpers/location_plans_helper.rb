module LocationPlansHelper

  APPROVAL_STATE_MAP = {
    'pending' => {
      css: 'warning',
      label: 'Un-approved'
    },
    'manager_approved' => {
      css: 'info',
      label: 'Manager approved'
    },
    'gm_approved' => {
      css: 'success',
      label: 'GM approved'
    }
  }

  def collective_state_label(state)
    %{<span class="label label-#{APPROVAL_STATE_MAP[state][:css]}">#{APPROVAL_STATE_MAP[state][:label]}</span>}.html_safe
  end

  def state_label(location_plan, size=nil)
    %{<a class="btn #{size == :small ? 'btn-xs': ''} btn-#{APPROVAL_STATE_MAP[location_plan.approval_state][:css]} disabled">#{APPROVAL_STATE_MAP[location_plan.approval_state][:label]}</a>}.html_safe
  end

  def action_links(location_plan)
    p = policy(location_plan)
    return unless p.change_state?

    ((p.state_downgrade? ? down_action_link(location_plan) : '') + ' ' +
     (p.state_upgrade? ? up_action_link(location_plan) :   '')
    ).html_safe
  end

  def life_cycle_info(location_plan)
    %{<h5><span> #{location_plan.life_cycle_max_total_hours.round(0)}</span><small> suggested (Life Cycle-#{location_plan.life_cycle})</small> </h5>}.html_safe
  end

  def life_cycle_tool_tip(location_plan)
    "#{location_plan.life_cycle_max_total_hours.round(0)} hours suggested (Life Cycle-#{location_plan.life_cycle})"
  end

  def life_cycle_diff(location_plan, grade = nil)
    grade ||= location_plan.chosen_grade
    diff = location_plan.life_cycle_max_total_hours - grade.unoptimized_summed_points['hours']
    sign = ''
    sign = '+' if diff < 0
    sign = '-' if diff > 0
    sign + number_with_delimiter(diff.round(0).abs).to_s
  end

  private

  # WARNING: Does NOT check schedule.active? or location_plan ownership!
  def down_action_link(location_plan)
    case location_plan.approval_state
      when 'manager_approved'
        text = current_user.manager? ? 'Cancel Approval' : "Cancel Manager's Approval"
        change_state_link(text, 'pending', 'btn-default', location_plan)
      when 'gm_approved'
        text = current_user.gm? ? 'Cancel Approval' : "Cancel GM's Approval"
        change_state_link(text, 'manager_approved', 'btn-default', location_plan)
      else
        ''
    end
  end

  # WARNING: Does NOT check schedule.active? or location_plan ownership!
  def up_action_link(location_plan)
    case location_plan.approval_state
      when 'pending'
        text = current_user.manager? ? 'Approve' : 'Manager Approval - Forced'
        btn_class = current_user.manager? ? 'btn-success' : 'btn-default'
        change_state_link(text, 'manager_approved', btn_class, location_plan)
      when 'manager_approved'
        text = current_user.gm? ? 'Approve' : 'GM Approval - Forced'
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
