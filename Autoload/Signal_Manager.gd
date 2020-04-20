extends Node2D

# keep track of all of the signals that can be emitted / connected -------------------------------

# is emitted from the dialogue window after an action is completed and the player has confirmed
signal finished_action_success
signal finished_action_failed

signal confirm_end_turn_yes
signal confirm_end_turn_no

signal finished_viewing_wake_up_text
signal finished_viewing_bedtime_text

signal cant_carry_item_dialogue_depot
signal finished_viewing_item_info_depot
signal finished_viewing_item_info_dining
signal already_have_effect_dialogue_dining
signal food_ate_dialogue_dining

# generic signal for finished viewing text (use with yield)
signal finished_viewing_text_generic
