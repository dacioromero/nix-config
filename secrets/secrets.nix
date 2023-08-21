let
  yubikey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQChdVQFQy29aCt5Su4COANlKmtRv1yWmccAjGCd8M0+bxlUqkfS/QDK05NxSDN+9Tzj/ge6myExbXeKbWMrxl6r4Ib5kpB6Db8WpuFmvXqyOc/L8d3ZFcWdn1i2ZYyXgp+ipkZlwYYaDqbaq7e+pfInNHDIirxMrULBy8n6FZo+EpIURhs8fNK8ujLKFQ94P4n+zGv9rwVPetXnYEUis4ro/qKwYzBPKGWQngnFLd0HthWR9MovixOuCe+mHcb1JZeHMOZi8/HfLsho0UfokMjHoQ0wZdQM7VbHjVZUuyhFV1aJHls4FOK67l88kbDUUouDCymgqMXZWYupHyp0LpnhzHm5WfPIkBaQR2InspdaH0mEztQ1iobCmM27A4XfuiAgtpzSPuKYH061kSGuEJGUf762o8Fo70W9pdkkaQx68OCVC99Ccqs7R+FJESHE9IVRmOyzTJKdjG/+LWqCgyv/OeNb7IxEF1Jqwh4D6ZHKb7BX5ccbTgBBRzs71WySFJimSRmuxbzVI4fmzYc1n1dyir/hEZEBpcpKIrryrDz6Hdl4AfwKOwwt9Wnf+aBlA45tbd52ORGgAojOQ+0kLQ1ZjFoyJU26v4WS3cTUMoi71U8Z9KaNHlTFS2msU8YXwQlH5o/r3cnnnRb3ZtEPGm833lDYUxo0+B3JP9J2j1rpnw== cardno:17_970_358";
  dacio_firebook-pro = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDM8KW5RvetpvizyQwiXco1vBNdOXotlRgMCnkoC/P3NALycTM6Isd1d5+z/Bqn+IYeESp0DKVrBLg6+YpTWLAnME10hBLDcqdv6N4Pfi9uQJ37PrIDhDSgqXlSGjnRnH6XFbC4HKMSpuw0nCbupDGFLnXGRUc+UmlP2EeGOJPsRNNJc3pX6vicmvAbm+wLmmIcxXNyXyopDVpeFJDh5drLR7npYzjvtYop1IMHX+0Lu7kCZhjEIvk7CE8lFTylcseB0fE6xaiPioDDpWlDxHW1+k2qsdPWNwqyc4Fu2d3Lka0j3Fr5Tpprs7nY+1LrI0kgyapnVRQSefPwzhwlmX6ScVIz6UQnCN+OMa2VfesAb4zbHo6fK7F1abdSF6JdiDGQzzLvigCwgCMatVsUDoX6Nett2AKE7IDfpmJiwVqfWXPiIsDsHIrXUOUu0QAXsvg+rq3xcGv/pYkaHKPsb9Ds5TQeX7xrTUA0fRq28tSkbCiMVuFNkUG9jf3oYFWl6Q0= dacio@firebook-pro.lan";
in
{
  "github-token.age".publicKeys = [ yubikey dacio_firebook-pro ];
}