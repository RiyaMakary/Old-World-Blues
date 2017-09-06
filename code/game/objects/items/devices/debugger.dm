/**
 * Multitool -- A multitool is used for hacking electronic devices.
 * TO-DO -- Using it as a power measurement tool for cables etc. Nannek.
 *
 */

/obj/item/device/debugger
	name = "debugger"
	desc = "Used to debug electronic equipment."
	icon = 'icons/obj/hacktool.dmi'
	icon_state = "hacktool-g"
	flags = CONDUCT
	force = 5.0
	w_class = ITEM_SIZE_SMALL
	throwforce = 5.0
	throw_range = 15
	throw_speed = 3
	var/mode = 1
	origin_tech = list(TECH_MAGNET = 5, TECH_ENGINEERING = 5)

/obj/item/device/debugger/resolve_attackby(obj/O, mob/user)
	var/obj/machinery/door/D = O
	if(istype(O, /obj/machinery/door) && (D.p_open))
		if(mode == 1)
			if(D.operating == -1)
				user << "<span class='warning'>There is a software error with the device.</span>"
			else
				user << SPAN_NOTE("The device's software appears to be fine.")
		else if (mode == 2)
			if(D.operating == -1)
				user << SPAN_NOTE("You start fixing the door device's software.")
				sleep(40)
				D.operating = 0
				user << SPAN_NOTE("You fixed the door device's software.")
			else
				user << SPAN_NOTE("The device's software appears to be fine.")
	else
		return ..()

/obj/item/device/debugger/attack_self(mob/user)
	if (mode == 1)
		mode = 2
		user << SPAN_NOTE("Changed mode to repair.")
	else
		mode = 1
		user << SPAN_NOTE("Changed mode to analysis.")