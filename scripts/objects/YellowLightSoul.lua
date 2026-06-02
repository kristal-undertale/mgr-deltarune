local YellowLightSoul, super = HookSystem.hookScript("YellowLightSoul")

function YellowLightSoul:init(x, y, undertale, angle)
    super.init(self, x, y, undertale, angle)

    self.can_use_bigshots = not self.undertale -- whether the soul can use bigshots
    self.charge_speed = 2
    self.allow_cheat = Kristal.getLibConfig("mgr-deltarune", "yellow_soul_allowcheat")

    self.hold_timer = 0
    self.charge_sfx = nil
end

function YellowLightSoul:update()
    super.update(self)

    if self.transitioning or Game.battle:getState() ~= "DEFENDING" then
        if self.charge_sfx then
            self.charge_sfx:stop()
            self.charge_sfx = nil
        end
        self.hold_timer = 0
        return
    end

    if not self:canShoot() then return end
    if not self:canUseBigShots() then return end

    if Input.released("confirm") then -- fire big shot
        if self.hold_timer >= 10 and self.hold_timer < 40 then -- didn't hold long enough, fire normal shot
            self:fireShot(false)
        elseif self.hold_timer >= 40 then -- fire big shot
            if self:canCheat() and Input.down("confirm") then -- they are cheating
                self:onCheat()
            end
            self:fireShot(true)
        end
        if not self:canCheat() then -- reset hold timer if cheating is disabled
            self.hold_timer = 0
        end
    end

    if Input.down("confirm") then -- charge a big shot
        self.hold_timer = self.hold_timer + DTMULT * self:getChargeSpeed()

        if self.hold_timer >= 20 and not self.charge_sfx then -- start charging sfx
            self.charge_sfx = Assets.getSound("yellowsoul/chargeshot_charge")
            self.charge_sfx:setLooping(true)
            self.charge_sfx:setPitch(0.1)
            self.charge_sfx:setVolume(0)
            local timer = 0
            Game.battle.timer:during(2/3, function()
                timer = timer + DT
                if self.charge_sfx then
                    self.charge_sfx:setVolume(MathUtils.rangeMap(timer, 0, 2 / 3, 0, 0.3))
                end
            end, function()
                if self.charge_sfx then
                    self.charge_sfx:setVolume(0.3)
                end
            end)
            self.charge_sfx:play()
        end
        if self.hold_timer >= 20 and self.hold_timer < 40 then
            self.charge_sfx:setPitch(MathUtils.rangeMap(self.hold_timer, 20, 40, 0.1, 1))
        end
    else
        self.hold_timer = 0
        if self.charge_sfx then
            self.charge_sfx:stop()
            self.charge_sfx = nil
        end
    end
end

function YellowLightSoul:draw()
    local r, g, b, a = self:getDrawColor()
    local heart_texture = Assets.getTexture(self.sprite.texture_path)
    local heart_w, heart_h = heart_texture:getDimensions()

    local charge_timer = self.hold_timer - 35
    if charge_timer > 0 then
        local scale = math.abs(math.sin(charge_timer / 10)) + 1
        Draw.setColor(r, g, b, a * 0.3)
        Draw.draw(heart_texture, -heart_w / 2 * scale, -heart_h / 2 * scale, 0, scale)

        scale = math.abs(math.sin(charge_timer / 14)) + 1.2
        Draw.setColor(r, g, b, a * 0.3)
        Draw.draw(heart_texture, -heart_w / 2 * scale, -heart_h / 2 * scale, 0, scale)
    end

    local circle_timer = math.min(self.hold_timer - 15, 35)
    if circle_timer > 0 then
        local circle = Assets.getTexture("effects/yellowsoul/charge")
        Draw.setColor(r, g, b, a * (circle_timer / 5))
        for i = 1, 4 do
            local angle = (i * math.pi / 2) - (circle_timer * math.rad(5))
            local x, y = math.cos(angle) * (35 - circle_timer), math.sin(angle) * (35 - circle_timer)
            local scale = MathUtils.rangeMap(circle_timer, 0, 35, 4, 2)
            x, y = x - circle:getWidth() / 2 * scale, y - circle:getHeight() / 2 * scale
            Draw.draw(circle, x, y, 0, scale)
        end
    end

    if charge_timer > 0 then
        self.color = {1, 1, 1, 1}
    end

    super.draw(self)

    if charge_timer > 0 then
        self.color = {r, g, b, a}
    end
end

function YellowLightSoul:onRemoveFromStage(stage)
    if super.onRemoveFromStage then
        super.onRemoveFromStage(self, stage)
    end

    if self.charge_sfx then
        self.charge_sfx:stop()
        self.charge_sfx = nil
    end
end

function YellowLightSoul:getChargeSpeed()
    return self.charge_speed
end

function YellowLightSoul:canUseBigShots() return self.can_use_bigshots end
function YellowLightSoul:canCheat() return self.allow_cheat end

function YellowLightSoul:fireShot(big)
    if big then
        Game.battle:addChild(YellowSoulBigShot(self.x, self.y, self.rotation + math.pi / 2))
        Assets.playSound("yellowsoul/chargeshot_fire")
        self.shot_timer = 5 -- delay normal shots after a bigshot
    else
        super.fireShot(self, big)
    end
end

function YellowLightSoul:onCheat()
    Game.battle.encounter.yellow_funnycheat = Game.battle.encounter.yellow_funnycheat + 1
end

return YellowLightSoul
