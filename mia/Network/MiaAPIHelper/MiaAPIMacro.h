//
//  MiaAPIMacro.h
//  mia
//
//  Created by linyehui on 2015/09/08.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#ifndef MiaMusicAPIMacro_h
#define MiaMusicAPIMacro_h

static NSString * const MiaAPIProtocolVersion				= @"1";
static NSString * const MiaAPIDefaultIMEI					= @"ios";

static NSString * const MiaAPIKey_ServerCommand				= @"C";
static NSString * const MiaAPIKey_ClientCommand				= @"c";
static NSString * const MiaAPIKey_Version					= @"r";
static NSString * const MiaAPIKey_Timestamp					= @"s";
static NSString * const MiaAPIKey_Values					= @"v";
static NSString * const MiaAPIKey_Return					= @"ret";
static NSString * const MiaAPIKey_Error						= @"err";

static NSString * const MiaAPICommand_Music_GetNearby		= @"Music.Get.Nearby";
static NSString * const MiaAPIKey_Latitude					= @"latitude";
static NSString * const MiaAPIKey_Longitude					= @"longitude";
static NSString * const MiaAPIKey_Start						= @"start";
static NSString * const MiaAPIKey_Item						= @"item";

static NSString * const MiaAPICommand_Music_GetMcomm		= @"Music.Get.Mcomm";
static NSString * const MiaAPIKey_ID						= @"id";

static NSString * const MiaAPICommand_Music_GetShlist		= @"Music.Get.Shlist";
static NSString * const MiaAPIKey_UID						= @"uid";

static NSString * const MiaAPICommand_Music_GetSharem		= @"Music.Get.Sharem";
static NSString * const MiaAPICommand_Music_GetByid			= @"Music.Get.Byid";
static NSString * const MiaAPIKey_MID						= @"mid";

static NSString * const MiaAPICommand_User_PostGuest		= @"User.Post.Guest";
static NSString * const MiaAPIKey_GUID						= @"guid";

static NSString * const MiaAPICommand_User_PostInfectm		= @"User.Post.Infectm";
static NSString * const MiaAPICommand_User_PostSkipm		= @"User.Post.Skipm";
static NSString * const MiaAPICommand_User_PostViewm		= @"User.Post.Viewm";
static NSString * const MiaAPIKey_spID						= @"spID";
static NSString * const MiaAPIKey_Address					= @"address";

static NSString * const MiaAPICommand_User_PostRcomm		= @"User.Post.Rcomm";

static NSString * const MiaAPICommand_User_PostPauth		= @"User.Post.Pauth";
static NSString * const MiaAPIKey_Type						= @"type";
static NSString * const MiaAPIKey_PhoneNumber				= @"phone";
static NSString * const MiaAPIKey_IMEI						= @"imei";

static NSString * const MiaAPICommand_User_PostRegister		= @"User.Post.Register";
static NSString * const MiaAPIKey_SCode						= @"scode";
static NSString * const MiaAPIKey_NickName					= @"nick";
static NSString * const MiaAPIKey_Password					= @"pass";

static NSString * const MiaAPICommand_User_PostLogin		= @"User.Post.Login";
static NSString * const MiaAPIKey_Pwd						= @"pwd";
static NSString * const MiaAPIKey_Dev						= @"dev";

static NSString * const MiaAPICommand_User_PostLogout		= @"User.Post.Logout";

static NSString * const MiaAPICommand_User_PostChangePwd	= @"User.Post.Cpwd";
static NSString * const MiaAPIKey_OldPwd					= @"opwd";
static NSString * const MiaAPIKey_NewPwd					= @"npwd";

static NSString * const MiaAPICommand_User_PostCnick		= @"User.Post.Cnick";
static NSString * const MiaAPICommand_User_PostGender		= @"User.Post.Gender";

static NSString * const MiaAPICommand_User_PostFavorite		= @"User.Post.Star";
static NSString * const MiaAPIKey_Act						= @"act";

static NSString * const MiaAPICommand_User_PostComment		= @"User.Post.Pcomm";
static NSString * const MiaAPIKey_sID						= @"sID";
static NSString * const MiaAPIKey_Comm						= @"comm";

static NSString * const MiaAPICommand_User_PostShare		= @"User.Post.Sharem";
static NSString * const MiaAPIKey_Note						= @"note";

static NSString * const MiaAPICommand_User_GetStart			= @"User.Get.Star";
static NSString * const MiaAPICommand_User_GetUinfo			= @"User.Get.Uinfo";
static NSString * const MiaAPICommand_User_GetClogo			= @"User.Get.Clogo";

static NSString * const MiaAPICommand_User_PushUnreadComm	= @"User.Push.UnreadComm";

#endif // MiaMusicAPIMacro_h