#define TOTAL_PAGES 9

/obj/structure/web_of_intrigue
	name = "Web of intrigue"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "web_of_intrigue"
	unacidable = 1
	anchored = 1
	var/list/pages[TOTAL_PAGES]

/obj/structure/web_of_intrigue/attackby(obj/item/W as obj, mob/user as mob)
	if(iswirecutter(W))
		for(var/i in 1 to TOTAL_PAGES)
			new /obj/item/weapon/paper (loc)
		for(var/i in 1 to round(TOTAL_PAGES/3))
			new /obj/item/stack/cable_coil/red(loc)
		qdel(src)
		return 1
	else if(istype(W, /obj/item/weapon/paper) || istype(W, /obj/item/weapon/photo))
		return attack_hand(user)
	else
		return ..()


/obj/structure/web_of_intrigue/attack_hand(mob/user as mob)
	var/dat = "<html><style>td{width:33px;height:33px;border:1px solid;}\
		table{table-layout:fixed;width:100%;height:100%;}\
		body{overflow:hidden;}img{height:100%+16px}</style><body><table>"
	for(var/i in 1 to TOTAL_PAGES)
		if(i%3 == 1)
			dat += "<tr>"
		dat += "<td>"
		if(pages[i])
			var/obj/item/elem = pages[i]
			dat += "<a href='?src=\ref[src];remove=[i]'>[elem.name]</a><hr>"
			if(istype(elem, /obj/item/weapon/paper))
				var/obj/item/weapon/paper/P = elem
				dat += P.info
			else if(istype(elem, /obj/item/weapon/photo))
				var/obj/item/weapon/photo/P = elem
				user << browse_rsc(P.img, "tmp_photo_[P.id].png")
				dat += "<img src='tmp_photo_[P.id].png'>"
		else
			var/obj/item/I = user.get_active_hand()
			if(istype(I, /obj/item/weapon/paper) || istype(I, /obj/item/weapon/photo))
				dat += "<a href='?src=\ref[src];attach=[i]'>Attach</a><hr>"
			else
				dat += "~~~<hr>"
		dat += "</td>"
		if(i%3 == 0)
			dat += "</tr>"

	dat += "</table></body></html>"
	user << browse(dat, "window=web;size=600x600")

/obj/structure/web_of_intrigue/Topic(href, href_list)
	if(href_list["attach"])
		var/page = text2num(href_list["attach"])
		if(pages[page])
			usr << "<span class='notice'>There is already something there.</span>"
			return
		var/obj/item/I = usr.get_active_hand()
		if(!istype(I, /obj/item/weapon/paper) && !istype(I, /obj/item/weapon/photo))
			usr << "<span class='notice'>You can't attach that.</span>"
			return
		usr.unEquip(I, src)
		pages[page] = I
	else if(href_list["remove"])
		var/page = text2num(href_list["remove"])
		if(!pages[page])
			return
		var/obj/item/I = pages[page]
		pages[page] = null
		usr.put_in_hands(I)
	spawn()
		attack_hand(usr)

# undef TOTAL_PAGES