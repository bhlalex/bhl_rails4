function check_forgot_password_paramters(){var r=!0;return(null==$("#email").val()||""==$("#email").val())&&($("#email_error").removeClass("invisible_error_msg"),$("#email_error").addClass("visible_error_msg"),r=!1),void 0==$("#recaptcha_response_field").val()||null!=$("#recaptcha_response_field").val()&&""!=$("#recaptcha_response_field").val()||($("#captcha_error").removeClass("invisible_error_msg"),$("#captcha_error").addClass("visible_error_msg"),r=!1),r}