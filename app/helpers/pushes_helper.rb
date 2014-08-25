module PushesHelper
  PUSH_ACTION_CLASS_MAP =  {
    'creates' => 'success',
    'updates' => 'warning',
    'deletes' => 'danger',
    'no_changes' => 'info'
  }

  def push_action_class(action)
    PUSH_ACTION_CLASS_MAP[action]
  end
end
