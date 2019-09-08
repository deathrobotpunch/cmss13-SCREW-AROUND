
/obj/item/legcuffs
	name = "legcuffs"
	desc = "Use this to keep prisoners in line."
	gender = PLURAL
	icon = 'icons/obj/items/items.dmi'
	icon_state = "handcuff"
	flags_atom = FPRINT|CONDUCT
	throwforce = 0
	w_class = SIZE_MEDIUM
	origin_tech = "materials=1"
	var/breakouttime = SECONDS_15

/obj/item/legcuffs/beartrap
	name = "bear trap"
	throw_speed = 2
	throw_range = 1
	icon_state = "beartrap0"
	desc = "A trap used to catch bears and other legged creatures."
	var/armed = 0

/obj/item/legcuffs/beartrap/attack_self(mob/user as mob)
	..()
	if(ishuman(user) && !user.stat && !user.is_mob_restrained())
		armed = !armed
		icon_state = "beartrap[armed]"
		to_chat(user, SPAN_NOTICE("[src] is now [armed ? "armed" : "disarmed"]"))

/obj/item/legcuffs/beartrap/Crossed(atom/movable/AM)
	if(armed)
		if(ismob(AM))
			var/mob/M = AM
			if(!M.buckled)
				if(ishuman(AM))
					if(isturf(src.loc))
						var/mob/living/carbon/H = AM
						if(H.m_intent == MOVE_INTENT_RUN)
							if(!H.legcuffed)
								H.legcuffed = src
								forceMove(H)
								H.legcuff_update()
							armed = 0
							icon_state = "beartrap0"
							playsound(loc, 'sound/effects/snap.ogg', 25, 1)
							to_chat(H, SPAN_DANGER("<B>You step on \the [src]!</B>"))
							feedback_add_details("handcuffs","B") //Yes, I know they're legcuffs. Don't change this, no need for an extra variable. The "B" is used to tell them apart.
							for(var/mob/O in viewers(H, null))
								if(O == H)
									continue
								O.show_message(SPAN_DANGER("<B>[H] steps on \the [src].</B>"), 1)
				if(isanimal(AM) && !istype(AM, /mob/living/simple_animal/parrot) && !istype(AM, /mob/living/simple_animal/construct) && !istype(AM, /mob/living/simple_animal/shade))
					armed = 0
					var/mob/living/simple_animal/SA = AM
					SA.health -= 20
	..()





//PREDATOR LEGCUFFS

/obj/item/legcuffs/yautja
	name = "hunting trap"
	throw_speed = 2
	throw_range = 2
	icon = 'icons/obj/items/weapons/predator.dmi'
	icon_state = "yauttrap0"
	desc = "A bizarre Yautja device used for trapping and killing prey."
	var/armed = 0
	layer = LOWER_ITEM_LAYER

	dropped(var/mob/living/carbon/human/mob) //Changes to "camouflaged" icons based on where it was dropped.
		if(armed)
			if(isturf(mob.loc))
				if(istype(mob.loc,/turf/open/gm/dirt))
					icon_state = "yauttrapdirt"
				else if (istype(mob.loc,/turf/open/gm/grass))
					icon_state = "yauttrapgrass"
				else
					icon_state = "yauttrap1"
		..()

/obj/item/legcuffs/yautja/attack_self(mob/user as mob)
	..()
	if(ishuman(user) && !user.stat && !user.is_mob_restrained())
		armed = 1
		anchored = 1
		icon_state = "yauttrap[armed]"
		to_chat(user, SPAN_NOTICE("[src] is now armed."))
		user.drop_held_item()


/obj/item/legcuffs/yautja/attack_hand(mob/living/carbon/human/user)
	if(isYautja(user))
		armed = 0
		anchored = 0
		icon_state = "yauttrap[armed]"
		to_chat(user, SPAN_NOTICE("[src] is now disarmed."))
	//Humans and synths don't know how to handle those traps!
	if(isHumanSynthStrict(user))
		if(armed)
			to_chat(user, "You foolishly reach out for \the [src]...")
			trapMob(user)
			return
	. = ..()

/obj/item/legcuffs/yautja/proc/trapMob(var/mob/living/carbon/H)
	if(armed)
		armed = 0
		anchored = 0
		icon_state = "yauttrap0"
		H.legcuffed = src
		src.loc = H
		H.legcuff_update()
		playsound(H,'sound/weapons/tablehit1.ogg', 25, 1)
		to_chat(H, "[htmlicon(src, H)] \red <B>You get caught in \the [src]!</B>")
		H.KnockDown(4)
		if(ishuman(H))
			H.emote("pain")
		feedback_add_details("handcuffs","B")

/obj/item/legcuffs/yautja/Crossed(atom/movable/AM)
	if(armed)
		if(ismob(AM))
			var/mob/M = AM
			if(!M.buckled)
				if(iscarbon(AM))
					if(isturf(src.loc))
						var/mob/living/carbon/H = AM
						if(isYautja(H))
							to_chat(H, SPAN_NOTICE("You carefully avoid stepping on the trap."))
							return
						if(H.m_intent == MOVE_INTENT_RUN)
							trapMob(H)
							for(var/mob/O in viewers(H, null))
								if(O == H)
									continue
								O.show_message(SPAN_WARNING("[htmlicon(src, O)] <B>[H] gets caught in \the [src].</B>"), 1)
				if(isanimal(AM) && !istype(AM, /mob/living/simple_animal/parrot) && !istype(AM, /mob/living/simple_animal/construct) && !istype(AM, /mob/living/simple_animal/shade))
					armed = 0
					var/mob/living/simple_animal/SA = AM
					SA.health -= 20
	..()


