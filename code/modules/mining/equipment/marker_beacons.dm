/*****************Marker Beacons**************************/
GLOBAL_LIST_INIT(marker_beacon_colors, list(
"Random" = FALSE, //not a true color, will pick a random color
"Burgundy" = LIGHT_COLOR_FLARE,
"Bronze" = LIGHT_COLOR_ORANGE,
"Yellow" = LIGHT_COLOR_YELLOW,
"Lime" = LIGHT_COLOR_SLIME_LAMP,
"Olive" = LIGHT_COLOR_GREEN,
"Jade" = LIGHT_COLOR_BLUEGREEN,
"Teal" = LIGHT_COLOR_LIGHT_CYAN,
"Cerulean" = LIGHT_COLOR_BLUE,
"Indigo" = LIGHT_COLOR_DARK_BLUE,
"Purple" = LIGHT_COLOR_PURPLE,
"Violet" = LIGHT_COLOR_LAVENDER,
"Fuchsia" = LIGHT_COLOR_PINK))

/obj/item/stack/marker_beacon
	name = "marker beacon"
	singular_name = "marker beacon"
	desc = "Prism-brand path illumination devices. Used by miners to mark paths and warn of danger."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "markerrandom"
	base_icon_state = "marker"
	armor = list(MELEE = 50, BULLET = 75, LASER = 75, ENERGY = 75, BOMB = 25, RAD = 100, FIRE = 25, ACID = 0)
	max_integrity = 50
	merge_type = /obj/item/stack/marker_beacon
	max_amount = 100
	var/picked_color = "random"

/// miners start with 10 of these
/obj/item/stack/marker_beacon/ten
	amount = 10

/// and they're bought in stacks of 1, 10, or 30
/obj/item/stack/marker_beacon/thirty
	amount = 30

/obj/item/stack/marker_beacon/Initialize(mapload)
	. = ..()
	update_icon(UPDATE_ICON_STATE)

/obj/item/stack/marker_beacon/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Use in-hand to place a [singular_name].</span>"
	. += "<span class='notice'>Alt-click to select a color. Current color is [picked_color].</span>"

/obj/item/stack/marker_beacon/update_icon_state()
	icon_state = "[base_icon_state][lowertext(picked_color)]"

/obj/item/stack/marker_beacon/attack_self__legacy__attackchain(mob/user)
	if(!isturf(user.loc))
		to_chat(user, "<span class='warning'>You need more space to place a [singular_name] here.</span>")
		return
	if(locate(/obj/structure/marker_beacon) in user.loc)
		to_chat(user, "<span class='warning'>There is already a [singular_name] here.</span>")
		return
	if(use(1))
		to_chat(user, "<span class='notice'>You activate and anchor [amount ? "a":"the"] [singular_name] in place.</span>")
		playsound(user, 'sound/machines/click.ogg', 50, 1)
		var/obj/structure/marker_beacon/M = new(user.loc, picked_color)
		transfer_fingerprints_to(M)

/obj/item/stack/marker_beacon/AltClick(mob/living/user)
	if(!istype(user) || ui_status(user, GLOB.physical_state) != UI_INTERACTIVE)
		return
	var/input_color = tgui_input_list(user, "Choose a color.", "Beacon Color", GLOB.marker_beacon_colors)
	if(!istype(user) || ui_status(user, GLOB.physical_state) != UI_INTERACTIVE)
		return
	if(input_color)
		picked_color = input_color
		update_icon(UPDATE_ICON_STATE)

/obj/structure/marker_beacon
	name = "marker beacon"
	desc = "A Prism-brand path illumination device. It is anchored in place and glowing steadily."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "markerrandom"
	base_icon_state = "marker"
	layer = BELOW_OPEN_DOOR_LAYER
	armor = list(MELEE = 50, BULLET = 75, LASER = 75, ENERGY = 75, BOMB = 25, RAD = 100, FIRE = 25, ACID = 0)
	max_integrity = 50
	anchored = TRUE
	light_range = 2
	light_power = 3
	var/remove_speed = 15
	var/picked_color

/obj/structure/marker_beacon/Initialize(mapload, set_color)
	. = ..()
	picked_color = set_color
	update_icon(UPDATE_ICON_STATE)

/obj/structure/marker_beacon/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		var/obj/item/stack/marker_beacon/M = new(loc)
		M.picked_color = picked_color
		M.update_icon(UPDATE_ICON_STATE)
	qdel(src)

/obj/structure/marker_beacon/examine(mob/user)
	. = ..()
	if(picked_color)
		. += "<span class='notice'>Alt-click to select a color. Current color is [picked_color].</span>"

/obj/structure/marker_beacon/update_icon_state()
	while(!picked_color || !GLOB.marker_beacon_colors[picked_color])
		picked_color = pick(GLOB.marker_beacon_colors)
	icon_state = "[base_icon_state][lowertext(picked_color)]-on"
	set_light(light_range, light_power, GLOB.marker_beacon_colors[picked_color])

/obj/structure/marker_beacon/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(user.incapacitated())
		to_chat(user, "<span class='warning'>You can't do that right now!</span>")
		return
	to_chat(user, "<span class='notice'>You start picking [src] up...</span>")
	if(do_after(user, remove_speed, target = src))
		var/obj/item/stack/marker_beacon/M = new(loc)
		M.picked_color = picked_color
		M.update_icon(UPDATE_ICON_STATE)
		transfer_fingerprints_to(M)
		user.put_in_hands(M)
		playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
		qdel(src)

/obj/structure/marker_beacon/attackby__legacy__attackchain(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/stack/marker_beacon))
		var/obj/item/stack/marker_beacon/M = I
		to_chat(user, "<span class='notice'>You start picking [src] up...</span>")
		if(do_after(user, remove_speed, target = src) && M.amount + 1 <= M.max_amount)
			M.add(1)
			playsound(src, 'sound/items/deconstruct.ogg', 50, 1)
			qdel(src)
			return
	return ..()

/obj/structure/marker_beacon/AltClick(mob/living/user)
	..()
	if(!istype(user) || ui_status(user, GLOB.physical_state) != UI_INTERACTIVE)
		return
	var/input_color = tgui_input_list(user, "Choose a color.", "Beacon Color", GLOB.marker_beacon_colors)
	if(!istype(user) || ui_status(user, GLOB.physical_state) != UI_INTERACTIVE)
		return
	if(input_color)
		picked_color = input_color
		update_icon(UPDATE_ICON_STATE)

/obj/structure/marker_beacon/dock_marker
	name = "docking beacon"
	desc = "An illumination device used to designate docking ports. It is anchored in place and pulsing steadily."
	icon_state = "dockingmarker"
	base_icon_state = "dockingmarker"
	flags = NODECONSTRUCT

/obj/structure/marker_beacon/dock_marker/update_icon_state()
	set_light(light_range, light_power, LIGHT_COLOR_BLUE)

/obj/structure/marker_beacon/dock_marker/attackby__legacy__attackchain()
	return

/obj/structure/marker_beacon/dock_marker/attack_hand()
	return

/obj/structure/marker_beacon/dock_marker/AltClick()
	return

/obj/structure/marker_beacon/dock_marker/collision
	name = "collision beacon"
	desc = "A Prism-brand collision illumination device. It is anchored in place and glowing steadily."
	icon_state = "markerburgundy-on"

/obj/structure/marker_beacon/dock_marker/collision/update_icon_state()
	set_light(light_range, light_power, LIGHT_COLOR_FLARE)
