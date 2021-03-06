/datum/power/changeling/panacea
	name = "Anatomic Panacea"
	desc = "Expels impurifications from our form; curing diseases, removing toxins, chemicals, radiation, and resetting our genetic code completely."
	helptext = "Can be used while unconscious.  This will also purge any reagents inside ourselves, both harmful and beneficial."
	enhancedtext = "We heal more toxins."
	genomecost = 1
	verbpath = /mob/living/proc/changeling_panacea

//Heals the things that the other regenerative abilities don't.
/mob/living/proc/changeling_panacea()
	set category = "Changeling"
	set name = "Anatomic Panacea (20)"
	set desc = "Clense ourselves of impurities."

	var/datum/changeling/changeling = changeling_power(20,0,100,UNCONSCIOUS)
	if(!changeling)
		return 0
	src.mind.changeling.chem_charges -= 20

	src << SPAN_NOTE("We cleanse impurities from our form.")

	var/mob/living/carbon/human/C = src

	C.radiation = 0
	C.sdisabilities = 0
	C.disabilities = 0
	C.reagents.clear_reagents()

	var/heal_amount = 5
	if(src.mind.changeling.recursive_enhancement)
		heal_amount = heal_amount * 2
		src << SPAN_NOTE("We will heal much faster.")
		src.mind.changeling.recursive_enhancement = 0

	for(var/i = 0, i<10,i++)
		if(C)
			C.adjustToxLoss(-heal_amount)
			sleep(10)

	return 1