extends Node2D

# keep track of all of the signals that can be emitted / connected -------------------------------

# is emitted from the dialogue window after an action is completed and the player has confirmed
signal finished_action_success
signal finished_action_failed

signal confirm_end_turn_yes
signal confirm_end_turn_no
