import engine
import Attacklist

attacks = {
	'face punch': FacePunch(),
	'scarf kick': ScarfKick(),
	'set fire': SetFire(),
	'call cavalry': CallCavalry(),
	'call lawyer': CallLawyer()
}

playgame = Engine()
playgame.play()
