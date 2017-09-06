/datum/power/changeling/cryo_sting
	name = "Cryogenic Sting"
	desc = "We silently sting a biological with a cocktail of chemicals that freeze them."
	helptext = "Does not provide a warning to the victim, though they will likely realize they are suddenly freezing.  Has \
	a three minute cooldown between uses."
	enhancedtext = "Increases the amount of chemicals injected."
	genomecost = 1
	verbpath = /mob/living/proc/changeling_cryo_sting

/mob/living/proc/changeling_cryo_sting()
	set category = "Changeling"
	set name = "Cryogenic Sting (20)"
	set desc = "Chills and freezes a biological creature."

	var/mob/living/carbon/T = changeling_sting(20,/mob/living/proc/changeling_cryo_sting)
	if(!T)
		return 0
	var/inject_amount = 10
	if(src.mind.changeling.recursive_enhancement)
		inject_amount = inject_amount * 1.5
		src << SPAN_NOTE("We inject extra chemicals.")
		src.mind.changeling.recursive_enhancement = 0
	if(T.reagents)
		T.reagents.add_reagent("cryotoxin", inject_amount)
	src.verbs -= /mob/living/proc/changeling_cryo_sting
	spawn(3 MINUTES)
		src << SPAN_NOTE("Our cryogenic string is ready to be used once more.")
		src.verbs |= /mob/living/proc/changeling_cryo_sting
	return 1

/datum/reagent/cryotoxin //A much more potent version of frost oil.
	name = "Cryotoxin"
	id = "cryotoxin"
	description = "Rapidly lowers the body's internal temperature."
	reagent_state = LIQUID
	color = "#B31008"

/datum/reagent/cryotoxin/affect_blood(var/mob/living/carbon/M, var/alien, var/removed)
	if(alien == IS_DIONA)
		return
	M.bodytemperature = max(M.bodytemperature - 30 * TEMPERATURE_DAMAGE_COEFFICIENT, 0)
	if(prob(3))
		M.emote("shiver")
	..()
	return