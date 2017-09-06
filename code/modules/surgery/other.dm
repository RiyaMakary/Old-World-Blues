//Procedures in this file: Inernal wound patching, Implant removal.
//////////////////////////////////////////////////////////////////
//					INTERNAL WOUND PATCHING						//
//////////////////////////////////////////////////////////////////


/datum/surgery_step/fix_vein
	priority = 2
	allowed_tools = list(
		/obj/item/weapon/FixOVein = 100,
		/obj/item/stack/cable_coil = 75
	)
	can_infect = 1
	blood_level = 1

	min_duration = 70
	max_duration = 90

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		if(!hasorgans(target))
			return 0

		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		if(!affected) return
		var/internal_bleeding = 0
		for(var/datum/wound/W in affected.wounds) if(W.internal)
			internal_bleeding = 1
			break

		return affected.open >= 2 && internal_bleeding

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		user.visible_message(
			"[user] starts patching the damaged vein in [target]'s [affected.name] with \the [tool].",
			"You start patching the damaged vein in [target]'s [affected.name] with \the [tool]."
		)
		target.custom_pain("The pain in [affected.name] is unbearable!",1)
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		user.visible_message(
				SPAN_NOTE("[user] has patched the damaged vein in [target]'s [affected.name] with \the [tool]."),
				SPAN_NOTE("You have patched the damaged vein in [target]'s [affected.name] with \the [tool].")
			)

		for(var/datum/wound/W in affected.wounds) if(W.internal)
			affected.wounds -= W
			affected.update_damages()
		if (ishuman(user) && prob(40)) user:bloody_hands(target, 0)

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		user.visible_message(
			SPAN_WARN("[user]'s hand slips, smearing [tool] in the incision in [target]'s [affected.name]!"),
			SPAN_WARN("Your hand slips, smearing [tool] in the incision in [target]'s [affected.name]!")
		)
		affected.take_damage(5, 0)

/datum/surgery_step/fix_dead_tissue		//Debridement
	priority = 2
	allowed_tools = list(
		/obj/item/weapon/scalpel = 100,
		/obj/item/weapon/material/knife = 75,
		/obj/item/weapon/material/shard = 50
	)

	can_infect = 1
	blood_level = 1

	min_duration = 110
	max_duration = 160

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		if(!hasorgans(target))
			return 0

		if (target_zone == O_MOUTH || target_zone == O_EYES)
			return 0

		var/obj/item/organ/external/affected = target.get_organ(target_zone)

		return affected && affected.open >= 2 && (affected.status & ORGAN_DEAD)

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		user.visible_message(
			"[user] starts cutting away necrotic tissue in [target]'s [affected.name] with \the [tool].",
			"You start cutting away necrotic tissue in [target]'s [affected.name] with \the [tool]."
		)
		target.custom_pain("The pain in [affected.name] is unbearable!",1)
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		user.visible_message(
				SPAN_NOTE("[user] has cut away necrotic tissue in [target]'s [affected.name] with \the [tool]."),
				SPAN_NOTE("You have cut away necrotic tissue in [target]'s [affected.name] with \the [tool].")
			)
		affected.open = 3
		playsound(target.loc, 'sound/effects/squelch1.ogg', 50, 1)

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		user.visible_message(
			SPAN_WARN("[user]'s hand slips, slicing an artery inside [target]'s [affected.name] with \the [tool]!"),
			SPAN_WARN("Your hand slips, slicing an artery inside [target]'s [affected.name] with \the [tool]!")
		)
		affected.createwound(CUT, 20, 1)

/datum/surgery_step/treat_necrosis
	priority = 2
	allowed_tools = list(
		/obj/item/weapon/reagent_containers/dropper = 100,
		/obj/item/weapon/reagent_containers/glass/beaker/bucket = 50,
		/obj/item/weapon/reagent_containers/glass/beaker/bottle = 75,
		/obj/item/weapon/reagent_containers/glass/beaker = 75,
		/obj/item/weapon/reagent_containers/spray = 50
	)

	can_infect = 0
	blood_level = 0

	min_duration = 50
	max_duration = 60

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		if (!istype(tool, /obj/item/weapon/reagent_containers))
			return 0

		var/obj/item/weapon/reagent_containers/container = tool
		if(!container.reagents.has_reagent("peridaxon"))
			return 0

		if(!hasorgans(target))
			return 0

		if (target_zone == O_MOUTH || target_zone == O_EYES)
			return 0

		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		return affected && affected.open == 3 && (affected.status & ORGAN_DEAD)

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		user.visible_message(
			"[user] starts applying medication to the affected tissue in [target]'s [affected.name] with \the [tool].",
			"You start applying medication to the affected tissue in [target]'s [affected.name] with \the [tool]."
		)
		target.custom_pain("Something in your [affected.name] is causing you a lot of pain!",1)
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/obj/item/organ/external/affected = target.get_organ(target_zone)

		if (!istype(tool, /obj/item/weapon/reagent_containers))
			return

		var/obj/item/weapon/reagent_containers/container = tool

		//technically it's contact, but the reagents are being applied to internal tissue
		var/trans = container.reagents.trans_to_mob(target, container.amount_per_transfer_from_this, CHEM_BLOOD)
		if (trans > 0)

			if(container.reagents.has_reagent("peridaxon"))
				affected.status &= ~ORGAN_DEAD

			user.visible_message(
					SPAN_NOTE("[user] applies [trans] units of the solution to affected tissue in [target]'s [affected.name]"),
					SPAN_NOTE("You apply [trans] units of the solution to affected tissue in [target]'s [affected.name] with \the [tool].")
				)

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/obj/item/organ/external/affected = target.get_organ(target_zone)

		if (!istype(tool, /obj/item/weapon/reagent_containers))
			return

		var/obj/item/weapon/reagent_containers/container = tool

		var/trans = container.reagents.trans_to_mob(target, container.amount_per_transfer_from_this, CHEM_BLOOD)

		user.visible_message(
			SPAN_WARN("[user]'s hand slips, applying [trans] units of the solution to the wrong place in [target]'s [affected.name] with the [tool]!"),
			SPAN_WARN("Your hand slips, applying [trans] units of the solution to the wrong place in [target]'s [affected.name] with the [tool]!")
		)

		//no damage or anything, just wastes medicine

/datum/surgery_step/hardsuit
	allowed_tools = list(
		/obj/item/weapon/weldingtool = 80,
		/obj/item/weapon/circular_saw = 60,
		/obj/item/weapon/pickaxe/plasmacutter = 100
	)

	can_infect = 0
	blood_level = 0

	min_duration = 120
	max_duration = 180

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		if(!istype(target))
			return 0
		if(istype(tool,/obj/item/weapon/weldingtool))
			var/obj/item/weapon/weldingtool/welder = tool
			if(!welder.isOn())
				return 0
		return (target_zone == BP_CHEST) && istype(target.back, /obj/item/weapon/rig) && !(target.back.canremove)

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message(
			"[user] starts cutting through the support systems of [target]'s [target.back] with \the [tool].",
			"You start cutting through the support systems of [target]'s [target.back] with \the [tool]."
		)
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

		var/obj/item/weapon/rig/rig = target.back
		if(!istype(rig))
			return
		rig.reset()
		user.visible_message(
				SPAN_NOTE("[user] has cut through the support systems of [target]'s [rig] with \the [tool]."),
				SPAN_NOTE("You have cut through the support systems of [target]'s [rig] with \the [tool].")
			)

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message(
			"<span class='danger'>[user]'s [tool] can't quite seem to get through the metal...</span>",
			"<span class='danger'>Your [tool] can't quite seem to get through the metal. It's weakening, though - try again.</span>"
		)