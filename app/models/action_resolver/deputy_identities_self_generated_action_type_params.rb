class ActionResolver::DeputyIdentitiesSelfGeneratedActionTypeParams < ActionResolver
  # for decreasing number of remaining actions in ResidentsRoleActionTypeParams

  def resolve(valid_results_hash, void_results_hash, city, trigger_id)
    # deputy identities vs. self generated action type params

    logger.info('MANUAL LOG - ' + self.class.name + '#' + __method__.to_s())

    self_generated_action_type_params_per_resident_id = {}

    unless valid_results_hash[ActionResultType::DeputyIdentities].nil?

      valid_results_hash[ActionResultType::SelfGenerated::ActionTypeParams].each { |self_generated_action_type_params_result_hash|
        self_generated_action_type_params_per_resident_id[self_generated_action_type_params_result_hash[:resident_id]] = self_generated_action_type_params_result_hash
      }

      decrease_available_actions(valid_results_hash, self_generated_action_type_params_per_resident_id)

    end

    unless void_results_hash[ActionResultType::DeputyIdentities].nil?
      if self_generated_action_type_params_per_resident_id.empty?
        valid_results_hash[ActionResultType::SelfGenerated::ActionTypeParams].each { |self_generated_action_type_params_result_hash|
          self_generated_action_type_params_per_resident_id[self_generated_action_type_params_result_hash[:resident_id]] = self_generated_action_type_params_result_hash
        }
      end

      decrease_available_actions(void_results_hash, self_generated_action_type_params_per_resident_id)

    end

    # / deputy identities vs. self generated action type params
  end

  def decrease_available_actions(results_hashes, self_generated_action_type_params_per_resident_id)
    results_hashes[ActionResultType::DeputyIdentities].each { |result_hash|
      unless result_hash[:result][ActionResultType::DeputyIdentities::KEY_SUCCESS]
        next
      end
      unless result_hash[:is_automatically_generated]
        next
      end


      action = result_hash[:action]
      if action.nil?
        next
      end

      self.modify_action_type_params(action)

      resident_id = action.resident_id
      role_id_string = action.role_id.to_s()
      action_type_id_string = ActionType::DEPUTY_IDENTITIES.to_s()

      sheriff_identities_action_type_params_hash = self_generated_action_type_params_per_resident_id[resident_id][:result][ActionResultType::SelfGenerated::ActionTypeParams::KEY_ACTION_TYPES_PARAMS][role_id_string][action_type_id_string]
      if sheriff_identities_action_type_params_hash[ActionType::DeputyIdentities::PARAM_LIFETIME_ACTIONS_COUNT]>0
        sheriff_identities_action_type_params_hash[ActionType::DeputyIdentities::PARAM_LIFETIME_ACTIONS_COUNT] -= 1
      else
        # counter is already at -1, so this action is infinitely available for this resident
      end
    }

  end

  def modify_action_type_params(action)
    if action.action_type_params.action_type_params_hash[ActionType::DeputyIdentities::PARAM_LIFETIME_ACTIONS_COUNT] > 0
      action.action_type_params.action_type_params_hash[ActionType::DeputyIdentities::PARAM_LIFETIME_ACTIONS_COUNT] -= 1
      action.action_type_params.save()
    end
  end

  def set_ordinal
    self.ordinal = 1555
  end

end