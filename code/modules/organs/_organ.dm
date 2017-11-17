/obj/item/organ
	name = "organ"
	icon = 'icons/obj/surgery.dmi'
	germ_level = 0

	// Strings.
	var/organ_tag = "organ"           // Unique identifier.
	var/parent_organ = BP_CHEST       // Organ holding this object.

	// Status tracking.
	var/status = 0                    // Various status flags
	var/vital                         // Lose a vital limb, die immediately.
	var/damage = 0                    // Current damage to the organ
	var/robotic = 0

	// Reference data.
	var/mob/living/carbon/human/owner // Current mob owning the organ.
	var/obj/item/organ/external/parent

	var/list/transplant_data          // Transplant match data.
	var/list/autopsy_data = list()    // Trauma data for forensics.
	var/list/trace_chemicals = list() // Traces of chemicals in the organ.

