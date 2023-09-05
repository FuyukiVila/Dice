require("pet.stauts.custom_function")

--状态栏
stauts_list = {
    stauts:new("经验", exp_change, true),
    stauts:new("体力", 0.20),
    stauts:new("饱食度", -0.20),
    stauts:new("口渴度", -0.20),
    stauts:new("心情", -0.15),
    stauts:new("健康度", health_change),
}