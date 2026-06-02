local Lib = {}

function Lib:init()
end

function Lib:postUpdate()
    for _, sprite in ipairs(Game.stage:getObjects(Sprite)) do
        local object = sprite.parent
        if object then
            local party = object.getPartyMember and object:getPartyMember() or object.chara
            if party and party:getDarknerShield() and Game:isLight() and object.darkner_shield == nil then
                object.darkner_shield = true
            end
            if object.darkner_shield and not object.darkner_shield_active then
                object.darkner_shield_background = DarknerProtectionEffect(0, 0, false)
                object.darkner_shield_foreground = DarknerProtectionEffect(0, 0, true)
                sprite.parent:addChild(object.darkner_shield_background)
                sprite.parent:addChild(object.darkner_shield_foreground)

                object.darkner_shield_active = true
            end
            if not object.darkner_shield and object.darkner_shield_active then
                object.darkner_shield_background:remove()
                object.darkner_shield_foreground:remove()
                object.darkner_shield_background = nil
                object.darkner_shield_foreground = nil
                object.darkner_shield_active = nil
            end
        end
    end
end

return Lib
