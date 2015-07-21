
#define ALPHA		1
#define BRAVO		2
#define CHARLIE		3
#define DELTA		4
#define NONE 		5

var/list/armormarkings = list()
var/list/armormarkings_sql = list()
var/list/helmetmarkings = list()
var/list/helmetmarkings_sql = list()
var/list/squad_colors = list(rgb(230,25,25), rgb(255,195,45), rgb(160,32,240), rgb(90,150,200))


/proc/initialize_marine_armor()
	var/i
	for(i=1, i<5, i++)
		var/image/armor
		var/image/helmet
		armor = image('icons/Marine/marine_armor.dmi',icon_state = "std-armor")
		armor.color = squad_colors[i]
		armormarkings += armor
		armor = image('icons/Marine/marine_armor.dmi',icon_state = "sql-armor")
		armor.color = squad_colors[i]
		armormarkings_sql += armor

		helmet = image('icons/Marine/marine_armor.dmi',icon_state = "std-helmet")
		helmet.color = squad_colors[i]
		helmetmarkings += helmet
		helmet = image('icons/Marine/marine_armor.dmi',icon_state = "sql-helmet")
		helmet.color = squad_colors[i]
		helmetmarkings_sql += helmet

/obj/item/clothing/head/helmet/marine2
	icon = 'icons/Marine/marine_armor.dmi'
	icon_state = "helmet"
	item_state = "helmet"
	icon_override = 'icons/Marine/marine_armor.dmi'
	name = "M10 Pattern Marine Helmet"
	desc = "A standard M10 Pattern Helmet. It reads on the label, 'The difference between an open-casket and closed-casket funeral. Wear on head for best results.'."
	armor = list(melee = 75, bullet = 60, laser = 50,energy = 10, bomb = 25, bio = 0, rad = 0)
	flags = FPRINT|TABLEPASS
	var/mob/living/carbon/human/wornby
	var/squad = 0
	var/rank = 0
	var/image/markingoverlay
	var/image/hugger_overlay
	var/hug_damage = 0
	anti_hug = 1

	New()
		..()
		hugger_overlay = image('icons/Marine/marine_armor.dmi',icon_state = "hugger_damage") //Initialize the overlay icon

	equipped(var/mob/living/carbon/human/mob, slot)
		update_squad_overlays(mob)
		..(mob, slot)

	dropped(var/mob/living/carbon/human/mob)
		update_squad_overlays(mob)
		..(mob)

	proc/update_squad_overlays(var/mob/living/carbon/human/H)
		if(istype(H,/mob/living/carbon/human)) //Are we on a person?
			if(!H || !istype(H)) return //Something went wrong, abort
			squad = get_squad_from_card(H) //Get the squad from the ID.
			rank = is_leader_from_card(H) //Leader?
			if(H.head == src && squad > 0 && squad < 5) //We're being worn on a valid squad.
				if(rank) //We are worn on a leader.
					markingoverlay = helmetmarkings_sql[squad]
				else //We are worn on a regular squaddie.
					markingoverlay = helmetmarkings[squad]
				overlays.Cut()
				overlays += markingoverlay //Add our overlay to the item.
				H.overlays_standing += markingoverlay  //Add the overlay to the person. Ughhhhhhhhhhh
				H.update_inv_head() //Update our wearer's icons so the people see it.
			else //We are NOT being worn, or our squad doesn't exist. Remove everything.
				overlays.Cut()
				if(hug_damage) overlays += hugger_overlay //Re-adds the hug damage overlay
				if(istype(markingoverlay) && markingoverlay in H.overlays_standing)
					H.overlays_standing.Remove(markingoverlay) //Dump the overlay off the person.
					H.update_inv_head() //Show it.
			if(H.head == src)
				if(hug_damage) H.overlays_standing += hugger_overlay //We're being worn, add the hugger marks.
			else
				if(hugger_overlay in H.overlays_standing) H.overlays_standing -= hugger_overlay //We were removed, remove the hugger marks.

	proc/add_hugger_damage() //This is called in XenoFacehuggers.dm to first add the overlay and set the var.
		hug_damage = 1
		overlays += hugger_overlay

/obj/item/clothing/suit/storage/marine2
	icon = 'icons/Marine/marine_armor.dmi'
	icon_state = "1"
	item_state = "armor"
	icon_override = 'icons/Marine/marine_armor.dmi'
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	cold_protection = UPPER_TORSO|LOWER_TORSO
	min_cold_protection_temperature = ARMOR_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection = UPPER_TORSO|LOWER_TORSO
	max_heat_protection_temperature = ARMOR_MAX_HEAT_PROTECTION_TEMPERATURE
	name = "M3 Pattern Marine Armor"
	desc = "A standard Colonial Marines M3 Pattern Chestplate. Protects the chest from ballistic rounds, bladed objects and accidents. It has a small leather pouch strapped to it for limited storage."
	blood_overlay_type = "armor"
	armor = list(melee = 50, bullet = 70, laser = 50, energy = 10, bomb = 25, bio = 0, rad = 0)
	siemens_coefficient = 0.7
	allowed = list(/obj/item/weapon/gun/,
		/obj/item/weapon/tank/emergency_oxygen,
		/obj/item/device/flashlight,
		/obj/item/ammo_magazine/,
		/obj/item/ammo_casing/,
		/obj/item/weapon/melee/baton,
		/obj/item/weapon/melee/stunprod,
		/obj/item/weapon/handcuffs,
		/obj/item/weapon/storage/fancy/cigarettes,
		/obj/item/weapon/flame/lighter,
		/obj/item/weapon/grenade,
		/obj/item/weapon/storage/bible,
		/obj/item/weapon/combat_knife)

	var/mob/living/carbon/human/wornby
	var/squad = 0
	var/rank = 0
	var/image/markingoverlay

	New(loc)
		..(loc)
		icon_state = "[rand(1,6)]"
		item_state = icon_state

	equipped(var/mob/living/carbon/human/mob, slot)
		update_squad_overlays(mob)
		..()

	dropped(var/mob/living/carbon/human/mob)
		update_squad_overlays(mob)
		..()

	proc/update_squad_overlays(var/mob/living/carbon/human/H)
		if(istype(H,/mob/living/carbon/human)) //Are we on a person?
			if(!H || !istype(H)) return //Something went wrong, abort
			squad = get_squad_from_card(H) //Get the squad from the ID.
			rank = is_leader_from_card(H) //Leader?
			if(H.wear_suit == src && squad > 0 && squad < 5) //We're being worn, in a valid squad.
				if(rank) //We are worn on a leader.
					markingoverlay = armormarkings_sql[squad]
				else //We are worn on a regular squaddie.
					markingoverlay = armormarkings[squad]
				overlays.Cut()
				overlays += markingoverlay //Add our overlay to the item.
				H.overlays_standing += markingoverlay  //Add the overlay to the person. This is SO FUCKING DUMB
				H.update_icons() //Update our wearer's icons so the people see it.
			else //We are NOT being worn, or our squad doesn't exist. Remove everything.
				overlays.Cut()
				if(istype(markingoverlay) && markingoverlay in H.overlays_standing)
					H.overlays_standing.Remove(markingoverlay) //Dump the overlay off the person.
					H.update_icons() //Show it.


/obj/item/clothing/suit/storage/marine_spec_armor
	icon = 'icons/Marine/marine_armor.dmi'
	icon_state = "xarmor"
	item_state = "armor"
	icon_override = 'icons/Marine/marine_armor.dmi'
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS
	cold_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	min_cold_protection_temperature = ARMOR_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	max_heat_protection_temperature = ARMOR_MAX_HEAT_PROTECTION_TEMPERATURE
	name = "B18 Defensive Armor"
	desc = "A heavy, rugged set of armor plates for when you really, really need to not die horribly. Slows you down though.\nComes with a tricord injector in each arm guard."
	blood_overlay_type = "armor"
	slowdown = 1
	armor = list(melee = 95, bullet = 95, laser = 80, energy = 50, bomb = 75, bio = 20, rad = 10)
	siemens_coefficient = 0.7
	var/injections = 2
	allowed = list(/obj/item/weapon/gun,
					/obj/item/weapon/tank/emergency_oxygen,
					/obj/item/device/flashlight,
					/obj/item/ammo_magazine,
					/obj/item/ammo_casing,
					/obj/item/weapon/flamethrower,
					/obj/item/device/mine,
					/obj/item/weapon/combat_knife)

	verb/inject()
		set name = "Create Injector"
		set category = "Object"
		set src in usr

		if(!usr.canmove || usr.stat || usr.restrained())
			return 0

		if(!injections)
			usr << "Your armor is all out of injectors."
			return 0

		if(usr.get_active_hand())
			usr << "Your active hand must be empty."
			return 0

		usr << "You feel a faint hiss and an injector drops into your hand."
		var/obj/item/weapon/reagent_containers/hypospray/autoinjector/tricord/O = new(usr)
		usr.put_in_active_hand(O)
		injections--
		playsound(src,'sound/machines/click.ogg', 20, 1)
		return

/obj/item/clothing/head/helmet/specrag
	icon = 'icons/Marine/marine_armor.dmi'
	icon_state = "band"
	item_state = "band"
	name = "Specialist head-rag"
	desc = "A hat worn by heavy-weapons operators to block sweat."
	anti_hug = 1

	flags = FPRINT|TABLEPASS|BLOCKHEADHAIR

/obj/item/clothing/head/helmet/marine2/heavy
	name = "B18 Helmet"
	icon_state = "xhelm"
	item_state = "helmet"
	desc = "The B18 Helmet that goes along with the B18 Defensive armor. It's heavy, reinforced, and protects more of the face."
	icon_override = 'icons/Marine/marine_armor.dmi'
	armor = list(melee = 95, bullet = 90, laser = 70,energy = 20, bomb = 35, bio = 10, rad = 10)
	anti_hug = 3

/obj/item/weapon/storage/box/heavy_armor
	name = "B18 defensive system crate"
	desc = "A large case containing an experiemental suit of B18 armor for the discerning specialist."
	icon = 'icons/Marine/marine_armor.dmi'
	icon_state = "armorchest"
	w_class = 5
	storage_slots = 2
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.

	New()
		..()
		spawn(1)
			new /obj/item/clothing/suit/storage/marine_spec_armor(src)
			new /obj/item/clothing/head/helmet/marine2/heavy(src)

/obj/item/clothing/suit/storage/marine_leader_armor
	icon = 'icons/Marine/marine_armor.dmi'
	icon_state = "7"
	item_state = "armor"
	icon_override = 'icons/Marine/marine_armor.dmi'
	body_parts_covered = UPPER_TORSO|LOWER_TORSO
	cold_protection = UPPER_TORSO|LOWER_TORSO
	min_cold_protection_temperature = ARMOR_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection = UPPER_TORSO|LOWER_TORSO
	max_heat_protection_temperature = ARMOR_MAX_HEAT_PROTECTION_TEMPERATURE
	name = "B12 Squad Leader Armor"
	desc = "A lightweight suit of carbon fiber body armor built for quick movement. Designed in a lovely forest green. Use it to toggle the built-in flashlight."
	blood_overlay_type = "armor"
	armor = list(melee = 45, bullet = 75, laser = 70, energy = 20, bomb = 15, bio = 0, rad = 0)
	siemens_coefficient = 0.7
	allowed = list(/obj/item/weapon/gun, /obj/item/device/binoculars, /obj/item/weapon/tank/emergency_oxygen, /obj/item/device/flashlight,/obj/item/ammo_magazine,/obj/item/ammo_casing,/obj/item/weapon/melee/baton, /obj/item/weapon/melee/stunprod, /obj/item/weapon/handcuffs, /obj/item/weapon/restraints, /obj/item/weapon/storage/fancy/cigarettes,/obj/item/weapon/flame/lighter,/obj/item/weapon/grenade, /obj/item/weapon/combat_knife)
	var/brightness_on = 7
	var/on = 0
	icon_action_button = "action_flashlight" //Adds it to the quick-icon list

	pickup(mob/user)
		if(on && src.loc != user)
			user.SetLuminosity(brightness_on)
			SetLuminosity(0)


	dropped(mob/user)
		if(on && src.loc != user)
			user.SetLuminosity(-brightness_on)
			SetLuminosity(brightness_on)

	attack_self(mob/user)
		if(!isturf(user.loc))
			user << "You cannot turn the light on while in this [user.loc]." //To prevent some lighting anomalities.
			return 0

		if(on) //Turn it off.
			if(user)
				user.SetLuminosity(-brightness_on)
			else //Shouldn't be possible, but whatever
				SetLuminosity(0)
			icon_state = "[initial(icon_state)]"
			on = 0
		else //Turn it on!
			on = 1
			if(user)
				user.SetLuminosity(brightness_on)
			else //Somehow
				SetLuminosity(brightness_on)
			icon_state = "[initial(icon_state)]-on"

		playsound(src,'sound/machines/click.ogg', 20, 1)
		update_clothing_icon()
		return 1


/proc/get_squad_from_card(var/mob/living/carbon/human/H)
	if(!istype(H))	return 0

	var/squad = 0
	var/obj/item/device/pda/I = H.wear_id
	var/obj/item/weapon/card/id/card = null

	if(I && istype(I))
		if(I.id)
			card = I.id
	else
		card = I

	if(!card || !istype(card))
		return 0

	if(findtext(card.assignment, "Alpha"))
		squad = 1
	if(findtext(card.assignment, "Bravo"))
		squad = 2
	if(findtext(card.assignment, "Charlie"))
		squad = 3
	if(findtext(card.assignment, "Delta"))
		squad = 4

	return squad

/proc/is_leader_from_card(var/mob/living/carbon/human/H)
	if(!istype(H)) return 0

	var/obj/item/device/pda/I = H.wear_id
	var/obj/item/weapon/card/id/card = null

	if(I && istype(I))
		if(I.id)
			card = I.id
	else
		card = I

	if(!card || !istype(card))
		return 0

	if(findtext(card.assignment, "Leader"))
		return 1

	return 0

/obj/item/weapon/card/id/equipped(var/mob/living/carbon/human/M, slot)
	if(!istype(M))
		return ..()

	var/obj/item/clothing/head/helmet/marine2/H = M.head
	var/obj/item/clothing/suit/storage/marine2/A = M.wear_suit

	if(!isnull(H) && istype(H)) H.update_squad_overlays(M)
	if(!isnull(A) && istype(A)) A.update_squad_overlays(M)

	..(M, slot)


/obj/item/clothing/suit/storage/marineMP
	icon = 'icons/Marine/marine_armor.dmi'
	icon_state = "mp"
	item_state = "armor"
	icon_override = 'icons/Marine/marine_armor.dmi'
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	cold_protection = UPPER_TORSO|LOWER_TORSO
	min_cold_protection_temperature = ARMOR_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection = UPPER_TORSO|LOWER_TORSO
	max_heat_protection_temperature = ARMOR_MAX_HEAT_PROTECTION_TEMPERATURE
	blood_overlay_type = "armor"
	armor = list(melee = 50, bullet = 85, laser = 50, energy = 10, bomb = 25, bio = 0, rad = 0)
	name = "M3 Pattern Marine Armor"
	desc = "A standard Colonial Marines M3 Pattern Chestplate. Protects the chest from ballistic rounds, bladed objects and accidents. It has a small leather pouch strapped to it for limited storage."