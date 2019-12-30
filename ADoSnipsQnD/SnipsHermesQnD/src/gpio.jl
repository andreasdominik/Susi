#
# helper function for GPIO switching
# on the local server (main)
#
#
# the GPIO number is read form a config entry: Light-GPIO=24
#


# """
#     exportGPIO(gpio, inout::Symbol)
#
# Prepare a GPIO for input or output.
#
# # Arguments:
# * gpio:  number of GPIO (*not* pin number)
# * inOut: one of `"in"` or `"out"`; direction of
#          GPIO mode.
#
# # Details:
# A GPIO must be exported *once* before it can be used. Export can/must
# be done at initialisation of an app (i.e. in `config.jl`).
# Using GPIOs is only possible if the user (here: `_snips-skills`) is
# in the group gpio (`sudo usermod -aG gpio _snips-skills`)
#
# **depecated**
# """
# function exportGPIO(gpio, inout::Symbol)
#
#     # shell = `echo $gpio > /sys/class/gpio/export`
#     # tryrun(shell, silent = true)
#     #
#     # shell = `echo $(String(inout)) > /sys/class/gpio/gpio$(gpio)/direction`
#     # tryrun(shell, silent = true)
#     try
#         write("/sys/class/gpio/unexport", "$gpio")
#     catch
#     end
#     try
#         write("/sys/class/gpio/export", "$gpio")
#         write("/sys/class/gpio/gpio$(gpio)/direction", "$inout")
#     catch
#         publishSay(TEXTS[:error_gpio])
#     end
# end
#
#
#
#
# """
#     setGPIO(gpio, onoff::Symbol)
#
# Switch a GPIO on or off.
#
# ## Arguments:
# * gpio: ID of GPIO (not pinID)
# * onoff: one of :on or :off
# """
# function setGPIO(gpio, onoff::Symbol)
#
#     if onoff == :on
#         value = 1
#     else
#         value = 0
#     end
#
#     # shell = `echo $value > /sys/class/gpio/gpio$(gpio)/value`
#     # tryrun(shell, errorMsg = TEXTS[:error_gpio])
#     try
#         write("/sys/class/gpio/gpio$(gpio)/value", "$value")
#     catch
#         publishSay(TEXTS[:error_gpio])
#     end
# end
"""
    setGPIO(gpio, onoff::Symbol)

Switch a GPIO on or off with pigs.

## Arguments:
* gpio: ID of GPIO (not pinID)
* onoff: one of :on or :off
"""
function setGPIO(gpio, onoff::Symbol)

    if onoff == :on
        value = 1
    else
        value = 0
    end

    shell = `pigs w $gpio $value`
    tryrun(shell, errorMsg = TEXTS[:error_gpio])
end
