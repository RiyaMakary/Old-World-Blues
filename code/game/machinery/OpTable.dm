/obj/machinery/optable
	name = "Operating Table"
	desc = "Used for advanced medical procedures."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "table2-idle"
	density = 1
	anchored = 1.0
	use_power = 1
	idle_power_usage = 1
	active_power_usage = 5
	var/mob/living/carbon/human/victim = null
	var/strapped = 0.0

	var/obj/machinery/computer/operating/computer = null

/obj/machinery/optable/New()
	..()
	for(var/dir in list(NORTH,EAST,SOUTH,WEST))
		computer = locate(/obj/machinery/computer/operating, get_step(src, dir))
		if(computer)
			computer.table = src
			break

/obj/machinery/optable/ex_act(severity)

	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				qdel(src)
				return
		if(3.0)
			if (prob(25))
				src.density = 0

/obj/machinery/optable/blob_act()
	if(prob(75))
		qdel(src)

/obj/machinery/optable/attack_hand(mob/user as mob)
	//TODO: DNA3 hulk
	/*
	if (HULK in usr.mutations)
		usr << text(SPAN_NOTE("You destroy the table."))
		visible_message("\red [usr] destroys the operating table!")
		src.density = 0
		qdel(src)
	*/
	return

/obj/machinery/optable/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(air_group || (height==0))
		return 1
	if(istype(mover) && mover.checkpass(PASSTABLE))
		return 1
	else
		return 0


/obj/machinery/optable/MouseDrop_T(obj/O as obj, mob/user as mob)

	if (!istype(O, /obj/item) || (user.get_active_hand() != O))
		return
	user.unEquip(O)
	if (O.loc != src.loc)
		step(O, get_dir(O, src))
	return

/obj/machinery/optable/proc/check_victim()
	if(locate(/mob/living/carbon/human, src.loc))
		var/mob/living/carbon/human/M = locate(/mob/living/carbon/human, src.loc)
		if(M.lying)
			src.victim = M
			icon_state = M.pulse ? "table2-active" : "table2-idle"
			return 1
	src.victim = null
	icon_state = "table2-idle"
	return 0

/obj/machinery/optable/process()
	check_victim()

/obj/machinery/optable/proc/take_victim(mob/living/carbon/target, mob/living/carbon/user as mob)
	if(!user.IsAdvancedToolUser() || !check_table(user) || !iscarbon(target))
		return
	if(target == user)
		if(user.incapacitated(INCAPACITATION_DISABLED))
			return
		user.visible_message(
			"[user] climbs on the operating table.",
			"You climb on the operating table."
		)
	else
		visible_message(SPAN_WARN("[target] has been laid on the operating table by [user]."))
		if(user.incapacitated())
			return
	target.resting = TRUE
	target.forceMove(loc)
	src.add_fingerprint(user)
	check_victim()

/obj/machinery/optable/MouseDrop_T(mob/target, mob/user)
	if(istype(user))
		take_victim(target,user)
	else
		return ..()

/obj/machinery/optable/verb/climb_on()
	set name = "Climb On Table"
	set category = "Object"
	set src in oview(1)

	take_victim(usr,usr)

/obj/machinery/optable/affect_grab(var/mob/user, var/mob/target)
	take_victim(target,user)
	return TRUE

/obj/machinery/optable/attackby(obj/item/weapon/W as obj, mob/living/carbon/user as mob)
	return

/obj/machinery/optable/proc/check_table(mob/living/carbon/patient as mob)
	if(src.victim)
		usr << SPAN_NOTE("<B>The table is already occupied!</B>")
		return 0

	if(patient.buckled)
		usr << SPAN_NOTE("<B>Unbuckle first!</B>")
		return 0

	return 1
