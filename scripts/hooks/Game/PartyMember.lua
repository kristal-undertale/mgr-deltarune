local PartyMember, super = HookSystem.hookScript(PartyMember)

function PartyMember:init()
    super.init(self)

    -- Gives a shield in the light world
    self.darkner_shield = false
end

function PartyMember:getDarknerShield()
    return self.darkner_shield
end

return PartyMember
