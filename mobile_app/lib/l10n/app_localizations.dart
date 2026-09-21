import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'ar': {
      // Splash Screen
      'app_name': 'إدارة الممتلكات',
      'welcome_subtitle': 'إدارة ممتلكاتك بكل سهولة',
      'splash_loading': 'جارٍ التحميل...',

      // Login Screen
      'login': 'تسجيل الدخول',
      'login_subtitle': 'أدخل بياناتك للوصول إلى حسابك',
      'email': 'البريد الإلكتروني',
      'email_hint': 'example@email.com',
      'password': 'كلمة المرور',
      'password_hint': '••••••••',
      'forgot_password': 'نسيت كلمة المرور؟',
      'no_account': 'ليس لديك حساب؟ ',
      'create_account': 'إنشاء حساب',
      'email_required': 'يرجى إدخال البريد الإلكتروني',
      'email_invalid': 'البريد الإلكتروني غير صحيح',
      'password_required': 'يرجى إدخال كلمة المرور',
      'password_min_length': 'كلمة المرور يجب أن تكون 6 أحرف على الأقل',
      
      // Sign Up Screen
      'sign_up': 'إنشاء حساب',
      'sign_up_subtitle': 'أنشئ حسابك للبدء',
      'name': 'الاسم الكامل',
      'name_hint': 'أدخل اسمك الكامل',
      'confirm_password': 'تأكيد كلمة المرور',
      'confirm_password_hint': 'أعد إدخال كلمة المرور',
      'already_have_account': 'لديك حساب بالفعل؟ ',
      'name_required': 'يرجى إدخال الاسم',
      'confirm_password_required': 'يرجى تأكيد كلمة المرور',
      'passwords_not_match': 'كلمات المرور غير متطابقة',
      'user_type': 'نوع المستخدم',
      'user_type_hint': 'اختر نوع حسابك',
      'user_type_tenant': 'مستأجر',
      'user_type_owner': 'مالك',
      'national_id': 'رقم الهوية / الجواز',
      'national_id_hint': 'أدخل رقم الهوية أو الجواز',
      'national_id_required': 'يرجى إدخال رقم الهوية أو الجواز',
      'permissions_info': 'معلومات الصلاحيات',
      'tenant_permissions': 'صلاحيات المستأجر',
      'owner_permissions': 'صلاحيات المالك',
      'tenant_permissions_list': '• متابعة عقارك المؤجر\n• إرسال طلبات الصيانة والإصلاحات\n• التواصل مع المالك\n• عرض الفواتير والمدفوعات\n• متابعة حالة الطلبات\n• ملاحظة: جميع عمليات الإضافة والتعديل والحذف تتم من نظام الويب فقط',
      'owner_permissions_list': '• متابعة جميع ممتلكاتك وعقارك\n• إرسال طلبات الصيانة والإصلاحات\n• متابعة المدفوعات والتقارير\n• عرض الإحصائيات والتقارير\n• متابعة حالة العقود والمستأجرين\n• ملاحظة: جميع عمليات الإضافة والتعديل والحذف تتم من نظام الويب فقط',
      'note': 'ملاحظة',
      'registration_note': 'بعد التسجيل، سيتم مراجعة طلبك من قبل الإدارة من نظام الويب. سيتم إشعارك عند الموافقة على حسابك. يمكنك بعدها متابعة ممتلكاتك وإرسال الطلبات فقط.',
      
      // Verification Screen
      'verification': 'التحقق الثنائي',
      'verification_subtitle': 'أدخل رمز التحقق المرسل إلى بريدك الإلكتروني',
      'verify': 'تحقق',
      'resend_code': 'إعادة إرسال الرمز',
      'code_required': 'يرجى إدخال رمز التحقق',
      'didnt_receive_code': 'لم تستلم الرمز؟',
      
      // Forgot Password Screen
      'forgot_password_title': 'نسيت كلمة المرور',
      'forgot_password_subtitle': 'أدخل بريدك الإلكتروني لإعادة تعيين كلمة المرور',
      'reset_password': 'إعادة تعيين كلمة المرور',
      'back_to_login': 'العودة لتسجيل الدخول',
      'reset_link_sent': 'تم إرسال رابط إعادة التعيين إلى بريدك الإلكتروني',
      
      // Dashboard
      'dashboard': 'لوحة التحكم',
      'welcome': 'مرحباً',
      'properties': 'الممتلكات',
      'tenants': 'المستأجرون',
      'contracts': 'العقود',
      'payments': 'المدفوعات',
      'reports': 'التقارير',
      'services': 'الخدمات',
      
      // Profile
      'profile': 'الملف الشخصي',
      'edit_profile': 'تعديل الملف الشخصي',
      'change_password': 'تغيير كلمة المرور',
      'settings': 'الإعدادات',
      'logout': 'تسجيل الخروج',
      'logout_confirmation': 'هل أنت متأكد من تسجيل الخروج؟',
      'cancel': 'إلغاء',
      'confirm': 'تأكيد',
      
      // Settings
      'general': 'عام',
      'language': 'اللغة',
      'notifications': 'الإشعارات',
      'enabled': 'مفعّل',
      'disabled': 'معطّل',
      'biometric_auth': 'المصادقة البيومترية',
      'biometric_auth_subtitle': 'استخدم البصمة أو Face ID',
      'security': 'الأمان',
      'two_factor_auth': 'التحقق الثنائي',
      'two_factor_auth_subtitle': 'إضافة طبقة حماية إضافية',
      'account': 'الحساب',
      'delete_account': 'حذف الحساب',
      'delete_account_subtitle': 'حذف حسابك بشكل دائم',
      'delete_account_confirmation': 'هل أنت متأكد من حذف حسابك؟ لا يمكن التراجع عن هذا الإجراء.',
      'delete': 'حذف',
      'choose_language': 'اختر اللغة',
      'arabic': 'العربية',
      'english': 'English',
      'language_changed_to': 'تم تغيير اللغة إلى',
      
      // My Properties
      'my_properties': 'ممتلكاتي',
      'add_property': 'إضافة ممتلك',
      'edit': 'تعديل',
      'share': 'مشاركة',
      'delete_item': 'حذف',
      'property_details': 'تفاصيل العقار',
      
      // Common
      'save': 'حفظ',
      'save_image': 'حفظ الصورة',
      'delete_image': 'حذف الصورة',
      'choose_from_gallery': 'اختر من المعرض',
      'take_photo': 'التقط صورة',
      'change_profile_picture': 'تغيير صورة الملف الشخصي',
      
      // Dashboard
      'overview': 'نظرة عامة على استثماراتك العقارية',
      'total_balance': 'إجمالي الرصيد المحصل',
      'last_update': 'آخر تحديث: اليوم',
      'rented_properties': 'العقارات المؤجرة',
      'active_portfolio': 'المحفظة الفعّالة',
      'view_all': 'عرض الكل',
      'revenue_expense_report': 'تقرير الإيرادات والمصروفات',
      'revenue_expense_subtitle': 'ملخص حركة الإيجارات والدخل لهذا الشهر',
      'rented_properties_report': 'تقرير العقارات المؤجرة',
      'rented_properties_subtitle': 'تفاصيل العقارات الحالية والمستأجرين',
      'construction_projects_report': 'تقرير المشاريع تحت الإنشاء',
      'construction_projects_subtitle': 'التفاصيل الكاملة للمشاريع والتكاليف المتوقعة',
      'maps': 'الخرائط',
      'maps_subtitle': 'عرض جميع العقارات على الخريطة',
      'ai_features': 'ميزات الذكاء الاصطناعي',
      'market_analysis': 'تحليل السوق',
      'image_analysis': 'تحليل الصور',
      'tenant_analysis': 'تحليل المستأجر',
      'financial_predictions': 'التنبؤات المالية',
      
      // Profile
      'account_settings': 'إعدادات الحساب',
      'security_privacy': 'الأمان والخصوصية',
      'privacy_policy': 'سياسة الخصوصية',
      'privacy_section_1_title': '1. جمع المعلومات',
      'privacy_section_1_content': 'نقوم بجمع المعلومات التي تقدمها لنا عند استخدام التطبيق، بما في ذلك اسمك وعنوان بريدك الإلكتروني ورقم هاتفك ومعلومات العقارات الخاصة بك.',
      'privacy_section_2_title': '2. استخدام المعلومات',
      'privacy_section_2_content': 'نستخدم المعلومات التي نجمعها لتقديم وتحسين خدماتنا، وإدارة حسابك، والتواصل معك بشأن خدماتنا.',
      'privacy_section_3_title': '3. حماية المعلومات',
      'privacy_section_3_content': 'نتخذ تدابير أمنية معقولة لحماية معلوماتك الشخصية من الوصول غير المصرح به أو التغيير أو الكشف أو التدمير.',
      'privacy_section_4_title': '4. مشاركة المعلومات',
      'privacy_section_4_content': 'لا نبيع أو نؤجر معلوماتك الشخصية لأطراف ثالثة. قد نشارك معلوماتك فقط في الحالات المحددة في هذه السياسة.',
      'preferences': 'التفضيلات',
      'currency': 'العملة',
      'appearance': 'تعديل المظهر',
      'change_background_theme': 'تغيير مظهر الخلفية',
      'choose_app_appearance': 'اختر مظهر الخلفية للتطبيق',
      'background_theme': 'مظهر الخلفية',
      'theme_light': 'فاتح',
      'theme_dark': 'داكن',
      'theme_auto': 'تلقائي',
      'help': 'المساعدة',
      'technical_support': 'الدعم الفني',
      
      // Property Status
      'rented': 'مؤجر',
      'vacant': 'شاغر',
      'tenant': 'المستأجر',
      'no_tenant': 'لا يوجد مستأجر حالي',
      'ready_for_rent': 'جاهزة للإيجار الفوري',
      'contract_ends': 'ينتهي العقد في',
      
      // Priority
      'urgent': 'عاجل',
      'medium': 'متوسط',
      'normal': 'عادي',
      'high': 'عالية',
      'low': 'منخفضة',
      
      // Edit Profile
      'full_name': 'الاسم الكامل',
      'enter_full_name': 'أدخل الاسم الكامل',
      'phone_number': 'رقم الهاتف',
      'enter_phone': 'أدخل رقم الهاتف',
      'address': 'العنوان (اختياري)',
      'enter_address': 'أدخل العنوان',
      'save_changes': 'حفظ التغييرات',
      'changes_saved': 'تم حفظ التغييرات بنجاح',
      'error_occurred': 'حدث خطأ',
      'signing_in': 'جاري تسجيل الدخول...',
      'demo_admin_account': 'حساب تجريبي للأدمن',
      'demo_app_account': 'حساب تجريبي للتطبيق',
      'fill_demo': 'تعبئة',
      'demo_login': 'دخول تجريبي',
      'enable_two_factor': 'تفعيل المصادقة الثنائية',
      'enable_two_factor_desc': 'قم بتفعيل المصادقة الثنائية لحماية حسابك بشكل أفضل',
      'select_region_type': 'اختر المنطقة والنوع',
      'analyze_market': 'تحليل السوق',
      'analyzing': 'جاري التحليل...',
      'real_estate_market_analysis': 'تحليل السوق العقاري',
      'two_factor_how': 'كيف تعمل المصادقة الثنائية؟',
      'two_factor_extra_layer': 'طبقة حماية إضافية',
      'two_factor_extra_layer_desc': 'بعد إدخال كلمة المرور، ستحتاج إلى رمز التحقق المرسل إلى هاتفك',
      'two_factor_breach': 'حماية من الاختراق',
      'two_factor_breach_desc': 'حتى لو عرف شخص ما كلمة مرورك، لن يتمكن من الوصول إلى حسابك',
      'two_factor_enabled_msg': 'تم تفعيل المصادقة الثنائية',
      'two_factor_disabled_msg': 'تم إلغاء تفعيل المصادقة الثنائية',
      'apartment': 'شقة',
      'villa': 'فيلا',
      'commercial_shop': 'محل تجاري',
      'land_plot': 'أرض',
      'riyadh': 'الرياض',
      'jeddah': 'جدة',
      'dammam': 'الدمام',
      'abu_dhabi': 'أبوظبي',
      'image_selected': 'تم اختيار الصورة بنجاح',
      'image_captured': 'تم التقاط الصورة بنجاح',
      'image_deleted': 'تم حذف الصورة',
      'image_saved': 'تم حفظ الصورة بنجاح',
      'tap_to_change': 'اضغط على الصورة لتغييرها',
      'delete_current_image': 'حذف الصورة الحالية',
      
      // Change Password
      'current_password': 'كلمة المرور الحالية',
      'new_password': 'كلمة المرور الجديدة',
      'confirm_new_password': 'تأكيد كلمة المرور الجديدة',
      'enter_current_password': 'يرجى إدخال كلمة المرور الحالية',
      'enter_new_password': 'يرجى إدخال كلمة المرور الجديدة',
      'password_changed': 'تم تغيير كلمة المرور بنجاح',
      'change_password_subtitle': 'أدخل كلمة المرور الحالية والجديدة',
      'update_current_password': 'تحديث كلمة المرور الحالية',
      'update_personal_information': 'تحديث معلوماتك الشخصية',
      
      // Home Shell
      'home': 'الرئيسية',
      'my_projects': 'مشاريعي',
      
      // Projects Screen
      'projects_under_construction': 'المشاريع تحت الإنشاء',
      'project_name': 'اسم المشروع',
      'project_location': 'الموقع',
      'completion_rate': 'نسبة الإنجاز',
      'total_cost': 'التكلفة الإجمالية',
      'delivery_date': 'تاريخ التسليم',
      'manager': 'المدير',
      'last_site_update': 'آخر تحديث للموقع',
      'view_engineering_plans': 'عرض المخططات الهندسية',
      'view_3d_model': 'استعراض مجسم ثلاثي الأبعاد',
      'expected_completion_date': 'تاريخ الإكتمال المتوقع',
      'project_manager': 'مدير المشروع',
      'last_update_on': 'آخر تحديث: {date}',
      'days_ago_short': 'قبل {days} أيام',
      'sar': 'د.إ',
      'opening_edit_page': 'جارٍ فتح صفحة التعديل...',
      'sharing_property': 'جارٍ مشاركة العقار...',
      'property_deleted': 'تم حذف العقار',
      
      // Contracts Screen
      'contracts_archive': 'أرشيف العقود (مع خيارات الإدارة)',
      'extend_contract': 'تمديد العقد',
      'file_lawsuit': 'رفع دعوى',
      'view_details': 'عرض التفاصيل',
      'contract_cancelled': 'تم إلغاء العقد',
      'cancel_contract': 'إلغاء العقد',
      'cancel_contract_confirmation': 'هل أنت متأكد من إلغاء هذا العقد؟',
      'confirm_cancel_contract_title': 'تأكيد إلغاء العقد',
      'cancel_contract_irreversible': 'هل أنت متأكد من إلغاء العقد؟ لا يمكن التراجع عن هذا الإجراء.',
      'cancel_reason': 'سبب الإلغاء',
      'cancel_reason_contract_end': 'انتهاء مدة العقد',
      'cancel_reason_tenant_violation': 'مخالفة من المستأجر',
      'cancel_reason_tenant_request': 'طلب من المستأجر',
      'cancel_reason_other': 'أسباب أخرى',
      'additional_details_optional': 'تفاصيل إضافية (اختياري)',
      'add_additional_details_hint': 'أضف تفاصيل إضافية...',
      'please_select_cancel_reason': 'يرجى اختيار سبب الإلغاء',
      'lawsuit_type': 'نوع الدعوى',
      'lawsuit_type_rent_nonpayment': 'عدم دفع الإيجار',
      'lawsuit_type_property_damage': 'تخريب الممتلكات',
      'lawsuit_type_contract_violation': 'مخالفة شروط العقد',
      'lawsuit_type_other': 'أخرى',
      'lawsuit_description': 'وصف الدعوى',
      'please_enter_lawsuit_description': 'يرجى إدخال وصف الدعوى',
      'lawsuit_description_hint': 'أدخل تفاصيل الدعوى...',
      'submit_lawsuit': 'رفع الدعوة',
      'lawsuit_filed_success': 'تم رفع الدعوى بنجاح',
      'please_select_lawsuit_type': 'يرجى اختيار نوع الدعوى',
      'new_contract_end_date': 'تاريخ انتهاء العقد الجديد',
      'select_contract_end_date': 'اختر تاريخ انتهاء العقد',
      'extend_contract_notes_hint': 'أضف ملاحظات حول تمديد العقد...',
      'contract_extended_success': 'تم تمديد العقد بنجاح',
      'search_property_or_tenant': 'ابحث باسم العقار أو المستأجر',
      'active': 'سارية',
      'expiring': 'شارفت على الانتهاء',
      'ended': 'منتهية',
      'ends_in_days': 'ينتهي خلال {days} أيام',
      'ends_in_day': 'ينتهي خلال {days} يوم',
      'ended_days_ago': 'انتهى منذ {days} يوم',
      'tenant_label': 'المستأجر: ',
      'end_date_label': 'تاريخ الانتهاء: ',
      
      // Services Screen
      'services_center': 'مركز الخدمات',
      'choose_service_you_need': 'اختر الخدمة التي تحتاجها',
      'legal_consultations': 'استشارات قانونية',
      'legal_consultations_subtitle': 'رفع قضية، استشارة قانونية، مراجعة عقود',
      'legal_consultation': 'استشارة قانونية',
      'engineering_consultations': 'استشارات هندسية',
      'engineering_consultations_subtitle': 'طلب استشارة، رفع مخططات، فحص عقار',
      'engineering_consultation': 'استشارة هندسية',
      'maintenance': 'الصيانة',
      'maintenance_subtitle': 'طلب إصلاح، سباكة، كهرباء، دهان',
      'repair_request': 'طلب إصلاح',
      'repair_request_subtitle': 'مستعجل / طارئ',
      
      // Service Request Screen
      'service_request': 'طلب خدمة',
      'error_selecting_images': 'حدث خطأ أثناء اختيار الصور',
      'problem_description': 'وصف المشكلة',
      'problem_description_hint': 'مثال: تبريد ضعيف، تسريب مياه من الوحدة الداخلية...',
      'notes_optional': 'اكتب ملاحظاتك هنا (اختياري)',
      'problem_details_required': 'يرجى كتابة تفاصيل العطل هنا ....',
      'please_enter_problem_description': 'يرجى إدخال وصف المشكلة',
      'choose_cleaning_type': 'اختر نوع التنظيف',
      'deep_cleaning': 'تنظيف عميق',
      'periodic_cleaning': 'تنظيف دوري',
      'attach_images': 'إرفاق صور',
      'attach_images_optional': 'إرفاق صور (اختياري)',
      'click_to_add_or_drag_images': 'انقر للإضافة أو اسحب وأفلت الصور',
      'add_problem_images': 'أضف صور للمشكلة',
      'suitable_appointment': 'الموعد المناسب',
      'choose_day': 'اختر اليوم',
      'choose_time': 'اختر الوقت',
      'choose_date': 'اختر التاريخ',
      'additional_notes': 'ملاحظات إضافية',
      'priority_level': 'مستوى الأولوية',
      'please_select_priority_level': 'يرجى اختيار مستوى الأولوية',
      'please_select_cleaning_type': 'يرجى اختيار نوع التنظيف',
      'request_confirmed': 'تم تأكيد الطلب',
      'request_submitted': 'تم تقديم الطلب',
      'confirm_request': 'تأكيد الطلب',
      'submit_request': 'تقديم الطلب',
      'submit_new_request': 'تقديم طلب جديد',
      'problem_type': 'نوع المشكلة',
      'select_problem_type': 'اختر نوع المشكلة',
      'please_select_problem_type': 'يرجى اختيار نوع المشكلة',
      'attach_photos': 'إرفاق صور (اختياري)',
      'click_to_attach': 'انقر للإرفاق أو اسحب الصور إلى هنا',
      'previous_requests': 'طلباتي السابقة',
      'order_number': 'رقم الطلب',
      'plumbing_problem': 'مشكلة في السباكة',
      'electricity_problem': 'مشكلة في الكهرباء',
      'ac_problem': 'مشكلة في التكييف',
      'cleaning_problem': 'مشكلة في النظافة',
      'other_problem': 'مشكلة أخرى',
      'kitchen_plumbing_problem': 'مشكلة في سباكة المطبخ',
      'request_submitted_successfully': 'تم تقديم الطلب بنجاح',
      
      // Maintenance Screen
      'maintenance_services': 'خدمات الصيانة',
      'current_requests': 'الطلبات الحالية',
      'request_history': 'سجل الطلبات',
      'choose_service_type': 'اختر نوع الخدمة',
      'electricity': 'كهرباء',
      'electricity_subtitle': 'أعطال وإضاءة',
      'plumbing': 'سباكة',
      'plumbing_subtitle': 'إصلاحات وتسريبات',
      'cleaning': 'تنظيف',
      'cleaning_subtitle': 'دوري وعميق',
      'ac': 'تكييف',
      'ac_subtitle': 'صيانة وتبريد',
      'in_progress': 'قيد التنفيذ',
      'completed': 'مكتمل',
      'no_requests': 'لا توجد طلبات',
      
      // Currency Settings Screen
      'usd': 'دولار أمريكي',
      'aed': 'د.إ',
      'aed_currency': 'درهم إماراتي',
      'sar_currency': 'ريال سعودي',
      'sar_symbol': 'ر.س',
      'eur': 'يورو',
      'gbp': 'جنيه إسترليني',
      'currency_changed_to': 'تم تغيير العملة إلى',
      
      // Help Support Screen
      'help_support': 'المساعدة والدعم',
      'contact_us': 'تواصل معنا',
      'call_us': 'اتصل بنا',
      'email_label': 'البريد الإلكتروني',
      'live_chat': 'الدردشة المباشرة',
      'live_chat_subtitle': 'متاح من 9 صباحاً إلى 5 مساءً',
      'live_chat_coming_soon': 'سيتم فتح الدردشة المباشرة قريباً',
      'faq': 'الأسئلة الشائعة',
      'faq_question_1': 'كيف أضيف عقار جديد؟',
      'faq_answer_1': 'يمكنك إضافة عقار جديد من صفحة "ممتلكاتي" ثم اضغط على زر الإضافة.',
      'faq_question_2': 'كيف أضيف عقد إيجار؟',
      'faq_answer_2': 'اذهب إلى صفحة "العقود" واضغط على زر "+" لإضافة عقد جديد.',
      'faq_question_3': 'كيف أطلب خدمة صيانة؟',
      'faq_answer_3': 'من صفحة "الخدمات"، اختر "الصيانة" ثم اختر نوع الخدمة المطلوبة.',
      'faq_question_4': 'كيف أرى التقارير المالية؟',
      'faq_answer_4': 'من لوحة التحكم، اضغط على "التقارير" لعرض جميع التقارير المالية.',
      
      // Wallet Screen
      'wallet': 'المحفظة',
      'financial_wallet': 'المحفظة المالية',
      'filter_transactions': 'فلترة المعاملات',
      'revenues': 'الإيرادات',
      'expenses': 'المصروفات',
      'this_month': 'هذا الشهر',
      'this_year': 'هذا العام',
      'total_expenses': 'إجمالي المصروفات',
      'monthly_income': 'الدخل الشهري',
      'bank_transfer_request': 'طلب تحويل بنكي',
      'bank_transfer_message': 'سيتم إرسال طلب التحويل البنكي إلى البنك. هل تريد المتابعة؟',
      'active_tenant': 'مستأجر نشط',
      'total_monthly_rent': 'إجمالي الإيجار الشهري',
      'proceed': 'متابعة',
      'transfer_request_sent': 'تم إرسال طلب التحويل بنجاح',
      'bank_transfer_account_selection': 'اختيار الحساب للتحويل',
      'account_type': 'نوع الحساب',
      'my_current_account': 'حسابي الحالي',
      'other_account': 'حساب آخر',
      'select_bank': 'اختر البنك',
      'account_number': 'رقم الحساب',
      'enter_account_number': 'أدخل رقم الحساب',
      'iban_optional': 'IBAN (اختياري)',
      'iban_hint': 'AE00 XXXX XXXX XXXX XXXX XXX',
      'account_holder_name': 'اسم صاحب الحساب',
      'enter_account_holder_name': 'أدخل اسم صاحب الحساب',
      'please_select_account_type': 'يرجى اختيار نوع الحساب',
      'please_enter_required_transfer_data': 'يرجى إدخال جميع البيانات المطلوبة',
      'other_bank': 'بنك آخر',
      'filter': 'فلترة',
      'transaction_log': 'سجل العمليات',
      
      // Financial Predictions Screen
      'choose_period': 'اختر الفترة',
      'three_months': '3 أشهر',
      'six_months': '6 أشهر',
      'twelve_months': '12 شهر',
      'generate_predictions': 'إنشاء التنبؤات',
      'revenue_forecast': 'التوقعات - الإيرادات',
      'for_next_period': 'للفترة القادمة',
      'first_month': 'الشهر الأول',
      'second_month': 'الشهر الثاني',
      'third_month': 'الشهر الثالث',
      'expected_total': 'المتوقع الإجمالي',
      'expense_forecast': 'التوقعات - المصروفات',
      'expected_maintenance': 'صيانة متوقعة',
      'taxes_fees': 'ضرائب ورسوم',
      'other_expenses': 'مصروفات أخرى',
      'stable': 'مستقر',
      'expected_net_profit': 'صافي الربح المتوقع',
      'expected_growth': 'نمو متوقع',
      'financial_recommendations': 'التوصيات المالية',
      'revenue_growth_recommendation': 'الإيرادات في حالة نمو مستمر، يُنصح بالاستثمار في عقارات إضافية',
      'expense_stable_recommendation': 'المصروفات مستقرة، يمكن تخصيص ميزانية للصيانة الوقائية',
      'net_profit_positive_recommendation': 'صافي الربح المتوقع إيجابي، فرصة جيدة للتوسع',
      
      // AI Assistant Screen
      'smart_assistant': 'المساعد الذكي',
      'ai_welcome_message': 'مرحباً! أنا مساعدك الذكي لإدارة العقارات. كيف يمكنني مساعدتك اليوم؟',
      'quick_actions': 'أوامر سريعة',
      'write_rental_contract': 'اكتب عقد إيجار',
      'write_property_ad': 'اكتب إعلان عقار',
      'analyze_property_performance': 'حلل أداء العقارات',
      'maintenance_recommendations': 'توصيات الصيانة',
      'estimate_rent_price': 'تقدير سعر الإيجار',
      'advanced_features': 'ميزات متقدمة',
      'write_message': 'اكتب رسالتك...',
      'write_contract_prompt': 'اكتب لي عقد إيجار',
      'write_ad_prompt': 'اكتب إعلان للعقار',
      'analyze_performance_prompt': 'حلل أداء عقاراتي',
      'maintenance_recommendations_prompt': 'ما هي توصيات الصيانة؟',
      'estimate_rent_prompt': 'ساعدني في تقدير سعر الإيجار',
      'ai_system_prompt': 'أنت مساعد ذكي متخصص في إدارة العقارات في الإمارات والخليج. أجب بالعربية بشكل واضح ومفيد.',
      'ai_sim_contract': 'يمكنني مساعدتك في كتابة عقد إيجار احترافي. يرجى تزويدي بالتفاصيل التالية:\n\n• اسم العقار\n• اسم المستأجر\n• قيمة الإيجار الشهري\n• مدة العقد (بالأشهر)\n• تاريخ البدء\n• أي شروط إضافية\n\nبعد ذلك سأقوم بإنشاء عقد إيجار شامل ومتوافق مع القوانين المحلية.',
      'ai_sim_ad': 'يمكنني كتابة إعلان جذاب ومؤثر لعقارك. يرجى إخباري بالتفاصيل التالية:\n\n• نوع العقار (شقة، فيلا، محل تجاري، إلخ)\n• الموقع بالتفصيل\n• المساحة\n• عدد الغرف والحمامات\n• المميزات الإضافية (مسبح، حديقة، موقف سيارات، إلخ)\n• سعر الإيجار\n\nسأكتب لك إعلاناً احترافياً يجذب المستأجرين المحتملين ويبرز مميزات عقارك.',
      'ai_sim_analysis': 'يمكنني تحليل أداء عقاراتك وتقديم تقرير شامل يتضمن:\n\n📊 الإحصائيات الرئيسية:\n• إجمالي الإيرادات الشهرية\n• معدل الإشغال\n• متوسط قيمة الإيجار\n\n🏆 أفضل الأداء:\n• العقارات الأكثر ربحية\n• العقارات الأقل تكلفة صيانة\n\n💡 التوصيات:\n• فرص تحسين العائد\n• نصائح لإدارة أفضل\n\nهل تريد تحليل جميع العقارات أم عقار محدد؟',
      'ai_sim_maintenance': 'يمكنني مساعدتك في إدارة الصيانة بكفاءة:\n\n🔧 الخدمات المتاحة:\n• تحديد مواعيد الصيانة الدورية\n• تتبع طلبات الصيانة\n• تقدير التكاليف\n• اقتراحات للتحسينات\n• تحليل الصور لاكتشاف المشاكل\n\n📅 الصيانة الدورية المقترحة:\n• فحص المكيفات: كل 6 أشهر (500-800 د.إ)\n• فحص السباكة: كل 3 أشهر (200-400 د.إ)\n• طلاء الجدران: كل 2-3 سنوات (5,000-15,000 د.إ)\n• فحص الأمان: شهرياً (100-200 د.إ)\n• تنظيف الخزانات: كل 6 أشهر (300-500 د.إ)\n\n💡 نصائح ذكية:\n• الصيانة الوقائية توفر 30-40% من التكاليف\n• الصيانة الدورية تزيد من قيمة العقار\n\nما هي المشكلة التي تواجهها حالياً؟',
      'ai_sim_valuation': 'يمكنني مساعدتك في تحديد سعر الإيجار المناسب بناءً على:\n\n📍 العوامل المؤثرة:\n• موقع العقار (الحي، القرب من الخدمات)\n• المساحة والمواصفات\n• حالة العقار (جديد، قديم، مجدد)\n• أسعار السوق في المنطقة\n• المميزات الإضافية\n\n💰 نطاق السعر المقترح:\nبناءً على موقع ومواصفات العقار، يمكنني تقدير نطاق سعري مناسب.\n\nأخبرني بموقع ومواصفات العقار وسأقترح عليك سعراً مناسباً.',
      'ai_sim_advice': 'يمكنني تقديم نصائح قيمة في:\n\n💼 إدارة العقارات:\n• كيفية اختيار المستأجرين المناسبين\n• إدارة العلاقات مع المستأجرين\n• تحسين العائد على الاستثمار\n\n🔧 الصيانة الوقائية:\n• جدولة الصيانة الدورية\n• اكتشاف المشاكل مبكراً\n• تقليل التكاليف\n\n📈 الاستثمار:\n• تحليل فرص الاستثمار\n• تقييم الربحية\n• التخطيط المالي\n\nما الموضوع الذي تريد النصيحة فيه تحديداً؟',
      'ai_sim_default': 'شكراً لسؤالك! أنا مساعدك الذكي لإدارة العقارات. يمكنني مساعدتك في:\n\n📝 الكتابة:\n• كتابة عقود الإيجار\n• كتابة إعلانات العقارات\n• كتابة رسائل للمستأجرين\n\n📊 التحليل:\n• تحليل الأداء المالي\n• تحليل السوق\n• تقارير مفصلة\n\n💡 النصائح:\n• نصائح لإدارة أفضل\n• توصيات للتحسين\n• إرشادات قانونية\n\nما الذي تريد المساعدة فيه تحديداً؟',
      'calendar': 'التقويم',
      'calendar_month': 'شهري',
      'calendar_week': 'أسبوعي',
      'calendar_day': 'يومي',
      'calendar_today': 'اليوم',
      'calendar_subtitle': 'مواعيد الإيجار والصيانة والعقود',
      'event_details': 'تفاصيل الحدث',
      'go_to_related': 'الانتقال للقسم ذي الصلة',
      'time': 'الوقت',
      'events': 'الأحداث',
      'no_events_today': 'لا توجد أحداث في هذا اليوم',
      'january': 'يناير',
      'february': 'فبراير',
      'march': 'مارس',
      'april': 'أبريل',
      'may': 'مايو',
      'june': 'يونيو',
      'july': 'يوليو',
      'august': 'أغسطس',
      'september': 'سبتمبر',
      'october': 'أكتوبر',
      'november': 'نوفمبر',
      'december': 'ديسمبر',
      
      // Notification Settings Screen
      'notification_settings': 'إعدادات الإشعارات',
      'enable_all_notifications': 'تفعيل جميع الإشعارات',
      'enable_all_notifications_subtitle': 'تفعيل أو إلغاء تفعيل جميع الإشعارات',
      'rent_reminders': 'تذكيرات الإيجار',
      'rent_reminders_subtitle': 'إشعارات بمواعيد استحقاق الإيجار',
      'maintenance_alerts': 'تنبيهات الصيانة',
      'maintenance_alerts_subtitle': 'إشعارات بطلبات الصيانة والحالة',
      'contract_expiry': 'انتهاء العقود',
      'contract_expiry_subtitle': 'تنبيهات بانتهاء العقود',
      'payment_reminders': 'تذكيرات المدفوعات',
      'payment_reminders_subtitle': 'إشعارات بالمواعيد المالية',
      'project_updates': 'تحديثات المشاريع',
      'project_updates_subtitle': 'إشعارات بتقدم المشاريع',
      'marketing_emails': 'البريد التسويقي',
      'marketing_emails_subtitle': 'رسائل وعروض خاصة',
      
      // My Properties Screen
      'opening_chat': 'جارٍ فتح المحادثة...',
      'view_details_property': 'عرض التفاصيل',
      'contract_ends_on': 'ينتهي العقد في',
      'ready_for_immediate_rent': 'جاهزة للإيجار الفوري',
      
      // Property Detail Screen
      'edit_property': 'تعديل عقار',
      'share_property': 'مشاركة',
      'delete_property': 'حذف',
      'property_description': 'وصف العقار',
      'tenant_data': 'بيانات المستأجر',
      'rent_details': 'تفاصيل الإيجار',
      'monthly_rent_amount_label': 'قيمة الإيجار الشهري:',
      'current_payment_status': 'حالة الدفعة الحالية:',
      'paid': 'مدفوعة',
      'next_due_date': 'تاريخ الاستحقاق القادم:',
      'media_gallery': 'معرض الصور والفيديوهات',
      'opening_image': 'فتح الصورة',
      'opening_video': 'فتح الفيديو',
      'loading_pdf': 'جارٍ تحميل ملف PDF...',
      'bathrooms_count': '{count} حمامات',
      'bedrooms_count': '{count} غرف',
      'area_display': '{area} م²',
      'contract_summary_property': 'العقار: {name}',
      'contract_summary_tenant': 'المستأجر: {name}',
      'contract_summary_rent': 'قيمة الإيجار: {amount} {currency}',
      'contract_summary_end_date': 'تاريخ انتهاء العقد: {date}',
      'contract_summary_next_due': 'موعد الدفعة القادمة: {date}',
      'contract_summary_status': 'الحالة: {status}',
      'no_contract_data_available': 'لا تتوفر بيانات عقد لهذا العقار حالياً.',
      'contract_pdf_server_note': 'ملف PDF الكامل سيُتاح عند ربطه من الخادم.',
      
      // Add Contract Screen
      'add_new_contract': 'إضافة عقد جديد',
      'contract_data': 'بيانات العقد',
      'select_property': 'اختر العقار',
      'please_select_property': 'يرجى اختيار العقار',
      'contract_type': 'نوع العقد',
      'monthly_rent': 'إيجار شهري',
      'annual_rent': 'إيجار سنوي',
      'temporary_rent': 'إيجار مؤقت',
      'please_select_contract_type': 'يرجى اختيار نوع العقد',
      'start_date': 'تاريخ البدء',
      'please_select_start_date': 'يرجى اختيار تاريخ البدء',
      'end_date': 'تاريخ الانتهاء',
      'please_select_end_date': 'يرجى اختيار تاريخ الانتهاء',
      'tenant_name': 'اسم المستأجر',
      'tenant_enter_full_name': 'أدخل الاسم الكامل',
      'please_enter_tenant_name': 'يرجى إدخال اسم المستأجر',
      'tenant_phone_number': 'رقم الهاتف',
      'please_enter_phone_number': 'يرجى إدخال رقم الهاتف',
      'monthly_rent_amount': 'قيمة الإيجار الشهري',
      'please_enter_rent_amount': 'يرجى إدخال قيمة الإيجار',
      'additional_notes_optional': 'ملاحظات إضافية (اختياري)',
      'any_additional_notes': 'أي ملاحظات أو شروط إضافية...',
      'contract_added_successfully': 'تم إضافة العقد بنجاح',
      
      // Wallet Screen - Transaction Types
      'rent_unit_number': 'إيجار الوحدة رقم',
      'rent_unit_101': 'إيجار الوحدة رقم 101',
      'rent_unit_205': 'إيجار الوحدة رقم 205',
      'maintenance_fees': 'رسوم صيانة',
      'profit_withdrawal': 'سحب أرباح',
      
      // Maintenance Screen
      'ac_repair': 'إصلاح مكيف الهواء',
      'kitchen_sink_leak': 'تسريب في حوض المطبخ',
      'ac_maintenance': 'صيانة مكيف الهواء',
      'new_maintenance_request': 'طلب خدمة صيانة جديدة',
      'request_number': 'طلب رقم',
      // Contact Tenant Screen
      'contact_tenant_title': 'التواصل مع المستأجر',
      'contact_tenant_of': 'مستأجر {property}',
      'contact_via_whatsapp': 'التواصل عبر واتساب',
      'phone_call': 'اتصال هاتفي',
      'contact_via_email': 'راسل بالبريد',
      'contact_via_sms': 'رسالة نصية',

      // Shared filters & labels
      'all': 'الكل',
      'pending': 'قيد الانتظار',
      'total_paid': 'إجمالي المدفوع',
      'pending_payments': 'المدفوعات المعلقة',
      'amount_label': 'المبلغ',
      'date_label': 'التاريخ',
      'property_label': 'العقار',
      'open_in_maps': 'فتح في الخرائط',
      'maps_open_error': 'لا يمكن فتح الخرائط. تأكد من تثبيت تطبيق الخرائط',
      'maps_open_failed': 'خطأ في فتح الخرائط',
      'properties_on_map': 'العقارات على الخريطة',
      'rent_amount_label': 'قيمة الإيجار',

      // Search (Arabic)
      'advanced_search': 'بحث متقدم',
      'search_property': 'ابحث عن عقار...',
      'filters': 'الفلاتر',
      'commercial': 'تجاري',
      'land': 'أرض',
      'madina': 'المدينة المنورة',
      'price_range': 'نطاق السعر (د.إ)',
      'from': 'من',
      'to': 'إلى',
      'area_range': 'المساحة (م²)',
      'search': 'بحث',
      'results': 'النتائج',

      // Reports
      'filter_reports': 'تصفية التقارير',
      'select_report_type': 'اختر نوع التقرير',
      'loading_report': 'جارٍ تحميل التقرير...',
      'revenue_expense_summary': 'ملخص الإيرادات والمصروفات',
      'net_profit': 'صافي الربح',
      'cash_flow_analysis': 'تحليل التدفق النقدي',
      'no_data_available': 'لا توجد بيانات متاحة',
      'load_more': 'تحميل المزيد',
      'latest_transactions': 'أحدث المعاملات',
      'view_report': 'عرض التقرير',
      'report_period': 'الفترة',
      'report_created_on': 'تاريخ الإنشاء',
      'report_data': 'البيانات',
      'download_pdf': 'تحميل PDF',
      'report_total_income': 'إجمالي الدخل',
      'report_transaction_count': 'عدد المعاملات',
      'report_avg_monthly_income': 'متوسط الدخل الشهري',
      'report_total_properties': 'إجمالي العقارات',
      'report_vacant_properties': 'العقارات الشاغرة',
      'report_active_projects': 'المشاريع النشطة',
      'report_avg_completion': 'متوسط نسبة الإنجاز',

      // Tenant analysis
      'government_employee': 'موظف حكومي',
      'private_employee': 'موظف خاص',
      'freelancer': 'أعمال حرة',
      'retired': 'متقاعد',
      'employment_status': 'حالة التوظيف',
      'has_previous_rental_record': 'لديه سجل إيجار سابق',
      'analyze_tenant_action': 'تحليل المستأجر',
      'risk_score': 'نقاط المخاطر',
      'analysis_details': 'تفاصيل التحليل',
      'financial_capacity': 'القدرة المالية',
      'employment_stability': 'الاستقرار الوظيفي',
      'previous_record': 'السجل السابق',
      'recommendation': 'التوصية',
      'risk_high': 'عالي',
      'risk_medium': 'متوسط',
      'risk_low': 'منخفض',
      'excellent': 'ممتاز',
      'good': 'جيد',
      'weak': 'ضعيف',
      'very_stable': 'مستقر جداً',
      'available': 'موجود',
      'not_available': 'غير موجود',
      'tenant_risk_high_recommendation': '⚠️ مخاطر عالية: يُنصح بعدم قبول هذا المستأجر. الدخل غير كافٍ أو عدم وجود سجل إيجار سابق.',
      'tenant_risk_medium_recommendation': '⚠️ مخاطر متوسطة: يمكن قبول المستأجر مع شروط إضافية مثل ضمان أو مراجعة دورية.',
      'tenant_risk_low_recommendation': '✅ مخاطر منخفضة: المستأجر مناسب. لديه دخل كافٍ واستقرار وظيفي جيد.',

      // Image analysis
      'smart_image_analysis': 'تحليل الصور الذكي',
      'upload_property_image': 'رفع صورة للعقار',
      'upload_multiple_images_hint': 'يمكنك رفع صورة واحدة أو عدة صور',
      'choose_image': 'اختر صورة',
      'analysis_results': 'نتائج التحليل',
      'overall_rating': 'التقييم العام',
      'property_condition_good': 'حالة العقار جيدة بشكل عام',
      'maps_tap_hint': 'اضغط على أي عقار في القائمة لفتح موقعه على الخرائط',
      'properties_count': 'العقارات',
      'avg_rent_price': 'متوسط سعر الإيجار',
      'price_range_label': 'نطاق الأسعار',
      'minimum': 'الأدنى',
      'average': 'المتوسط',
      'maximum': 'الأعلى',
      'market_trends': 'اتجاهات السوق',
      'monthly_change': 'التغير الشهري',
      'yearly_change': 'التغير السنوي',
      'occupancy_rate': 'معدل الإشغال',
      'market_rec_1': 'السوق في حالة نمو مستمر، يُنصح برفع السعر بنسبة 5-10%',
      'market_rec_2': 'المنطقة تتمتع بإقبال عالي، فرصة جيدة للاستثمار',
      'market_rec_3': 'معدل الإشغال مرتفع، يمكنك التفاوض على شروط أفضل',
      'per_month': 'شهري',
      'recommendations_title': 'التوصيات',

      // Admin panel
      'property_admin': 'إدارة الأملاك',
      'admin_settings': 'إعدادات لوحة الأدمن',
      'admin_stack': 'المشروع: Flutter + Laravel',
      'owners': 'الملاك',
      'operations': 'مركز العمليات',
      'financial_admin': 'الإدارة المالية',
      'users': 'المستخدمين',
      'retry': 'إعادة المحاولة',
      'demo_data_banner': 'عرض بيانات تجريبية — لا يوجد اتصال بالخادم',
      'web_only_action': 'هذه العملية متاحة من لوحة الويب فقط',
      'settings_saved': 'تم حفظ الإعدادات',
      'push_notifications_note': 'الإشعارات تُجلب من Laravel API — حدّث القائمة من شاشة الإشعارات',
      'loading_properties': 'جاري تحميل العقارات...',
      'loading_contracts': 'جاري تحميل العقود...',
      'loading_tenants': 'جاري تحميل المستأجرين...',
      'loading_wallet': 'جاري تحميل المحفظة...',
      'loading_dashboard': 'جاري تحميل لوحة التحكم...',
      'loading_reports': 'جاري تحميل التقارير...',
      'loading_notifications': 'جاري تحميل الإشعارات...',
      'loading_projects': 'جاري تحميل المشاريع...',
      'loading_maintenance': 'جاري تحميل طلبات الصيانة...',
      'loading_maps': 'جاري تحميل الخريطة...',
      'loading_search': 'جاري البحث...',
      'no_search_results': 'لا توجد نتائج مطابقة',
      'mark_all_read': 'تحديد الكل كمقروء',
      'not_found': 'غير موجود',
      'operation_successful': 'تمت العملية بنجاح',
      'operation_failed': 'فشلت العملية — تحقق من الباكند',
      'saved_successfully': 'تم الحفظ بنجاح',
      'save_failed': 'فشل الحفظ — تحقق من الباكند',
      'delete_failed': 'فشل الحذف',
      'add_owner': 'إضافة مالك',
      'add_tenant': 'إضافة مستأجر',
      'add_contract': 'إضافة عقد',
      'search_owners': 'بحث في الملاك...',
      'search_users': 'بحث في المستخدمين...',
      'no_owners': 'لا ملاك',
      'no_contracts': 'لا عقود',
      'no_tenants': 'لا مستأجرين',
      'no_properties_found': 'لا توجد عقارات',
      'no_notifications': 'لا إشعارات',
      'notifications_filtered_empty': 'لا إشعارات مطابقة لتفضيلاتك — راجع إعدادات الإشعارات',
      'no_reports': 'لا تقارير',
      'no_payments': 'لا مدفوعات',
      'no_transfers': 'لا تحويلات',
      'joined': 'انضم',
      'balance': 'الرصيد',
      'delete_owner_title': 'حذف المالك؟',
      'delete_owner_message': 'سيتم حذف المالك من النظام.',
      'owner_profile': 'ملف المالك',
      'total_revenue_label': 'إجمالي الإيرادات',
      'join_date': 'تاريخ الانضمام',
      'properties_count_label': 'عدد العقارات',
      'owner_properties': 'عقارات المالك',
      'delete_contract_title': 'حذف العقد؟',
      'contract_details': 'تفاصيل العقد',
      'tenant_information': 'معلومات المستأجر',
      'label_name': 'الاسم',
      'mobile_number': 'رقم الجوال',
      'next_payment': 'الدفع القادم',
      'remaining_label': 'المتبقي',
      'days_count': '{count} يوم',
      'view_pdf': 'عرض PDF',
      'renew_contract': 'تجديد',
      'contract_rental_title': 'عقد إيجار - {property}',
      'parties': 'الأطراف',
      'term_and_finances': 'المدة والمالية',
      'start_label': 'البداية',
      'end_label': 'النهاية',
      'deposit': 'التأمين',
      'delete_tenant_title': 'حذف المستأجر؟',
      'tenant_details': 'تفاصيل المستأجر',
      'rent_label': 'الإيجار',
      'delete_property_title': 'حذف العقار؟',
      'basic_info': 'المعلومات الأساسية',
      'area_label': 'المساحة',
      'bedrooms': 'الغرف',
      'bathrooms': 'الحمامات',
      'floor': 'الطابق',
      'monthly_revenue': 'الإيراد الشهري',
      'description': 'الوصف',
      'edit_contract': 'تعديل عقد',
      'edit_tenant': 'تعديل مستأجر',
      'edit_owner': 'تعديل مالك',
      'property_name': 'اسم العقار',
      'type_label': 'النوع',
      'area_sqm': 'المساحة (م²)',
      'under_construction': 'قيد الإنشاء',
      'properties_unit': 'عقار',
      'users_unit': 'مستخدم',
      'unread': 'غير مقروء',
      'maintenance_operations': 'طلبات الصيانة والعمليات',
      'issue': 'المشكلة',
      'technician': 'الفني',
      'transfers': 'التحويلات',
      'due_label': 'استحقاق',
      'connected_to_api': 'متصل بـ Laravel API',
      'recent_activity': 'آخر النشاطات',
      'no_recent_activity': 'لا نشاطات حديثة من API',
      'open_maintenance': 'صيانة مفتوحة',
      'active_contracts': 'عقود نشطة',
      'this_week': 'هذا الأسبوع',
      'admin_role': 'مدير',
      'admin_more': 'المزيد',
      'analytics': 'التحليلات',
      'tasks': 'المهام',
      'messages': 'الرسائل',
      'registration_requests': 'طلبات التسجيل',
      'add_user': 'إضافة مستخدم',
      'edit_user': 'تعديل مستخدم',
      'delete_user_title': 'حذف المستخدم؟',
      'delete_user_message': 'سيتم حذف المستخدم من النظام.',
      'approve': 'موافقة',
      'reject': 'رفض',
      'no_tasks': 'لا مهام',
      'no_messages': 'لا رسائل',
      'no_registration_requests': 'لا طلبات تسجيل',
      'financial_flow': 'التدفق المالي',
      'password_confirm': 'تأكيد كلمة المرور',
      'revenue_chart': 'الإيرادات الشهرية',
      'occupancy_overview': 'نظرة الإشغال',
      'mobile_requests': 'طلبات التطبيق',
      'role': 'الدور',
      'required_field': 'مطلوب',
      'none_option': '— بدون —',
      'start_date_format': 'تاريخ البداية (YYYY-MM-DD)',
      'end_date_format': 'تاريخ النهاية (YYYY-MM-DD)',
      'contract_start_format': 'بداية العقد (YYYY-MM-DD)',
      'contract_end_format': 'نهاية العقد (YYYY-MM-DD)',
      'rent_amount': 'قيمة الإيجار',
      'owner': 'المالك',
      'overview_short': 'نظرة عامة',
      'sqm_unit': 'م²',
      'status_label': 'الحالة',
      'phone_short': 'الهاتف',
      'name_label': 'الاسم',
      'search_hint': 'بحث...',
      'end_date_short': 'انتهاء',
      'contract_section': 'العقد',
    },
    'en': {
      // Splash Screen
      'app_name': 'Property Management',
      'welcome_subtitle': 'Manage your properties with ease',
      'splash_loading': 'Loading...',

      // Login Screen
      'login': 'Login',
      'login_subtitle': 'Enter your credentials to access your account',
      'email': 'Email',
      'email_hint': 'example@email.com',
      'password': 'Password',
      'password_hint': '••••••••',
      'forgot_password': 'Forgot Password?',
      'no_account': "Don't have an account? ",
      'create_account': 'Create Account',
      'email_required': 'Please enter your email',
      'email_invalid': 'Invalid email address',
      'password_required': 'Please enter your password',
      'password_min_length': 'Password must be at least 6 characters',
      
      // Sign Up Screen
      'sign_up': 'Sign Up',
      'sign_up_subtitle': 'Create your account to get started',
      'name': 'Full Name',
      'name_hint': 'Enter your full name',
      'confirm_password': 'Confirm Password',
      'confirm_password_hint': 'Re-enter your password',
      'already_have_account': 'Already have an account? ',
      'name_required': 'Please enter your name',
      'confirm_password_required': 'Please confirm your password',
      'passwords_not_match': 'Passwords do not match',
      'user_type': 'User Type',
      'user_type_hint': 'Select your account type',
      'user_type_tenant': 'Tenant',
      'user_type_owner': 'Owner',
      'national_id': 'National ID / Passport',
      'national_id_hint': 'Enter your national ID or passport number',
      'national_id_required': 'Please enter your national ID or passport number',
      'permissions_info': 'Permissions Information',
      'tenant_permissions': 'Tenant Permissions',
      'owner_permissions': 'Owner Permissions',
      'tenant_permissions_list': '• Track your rented property\n• Send maintenance and repair requests\n• Communicate with owner\n• View bills and payments\n• Track request status\n• Note: All add, edit, and delete operations are done from the web system only',
      'owner_permissions_list': '• Track all your properties and real estate\n• Send maintenance and repair requests\n• Track payments and reports\n• View statistics and reports\n• Track contract and tenant status\n• Note: All add, edit, and delete operations are done from the web system only',
      'note': 'Note',
      'registration_note': 'After registration, your request will be reviewed by the administration from the web system. You will be notified when your account is approved. After that, you can track your properties and send requests only.',
      
      // Verification Screen
      'verification': 'Two-Factor Authentication',
      'verification_subtitle': 'Enter the verification code sent to your email',
      'verify': 'Verify',
      'resend_code': 'Resend Code',
      'code_required': 'Please enter the verification code',
      'didnt_receive_code': "Didn't receive the code?",
      
      // Forgot Password Screen
      'forgot_password_title': 'Forgot Password',
      'forgot_password_subtitle': 'Enter your email to reset your password',
      'reset_password': 'Reset Password',
      'back_to_login': 'Back to Login',
      'reset_link_sent': 'Reset link has been sent to your email',
      
      // Dashboard
      'dashboard': 'Dashboard',
      'welcome': 'Welcome',
      'properties': 'Properties',
      'tenants': 'Tenants',
      'contracts': 'Contracts',
      'payments': 'Payments',
      'reports': 'Reports',
      'services': 'Services',
      
      // Profile
      'profile': 'Profile',
      'edit_profile': 'Edit Profile',
      'change_password': 'Change Password',
      'settings': 'Settings',
      'logout': 'Logout',
      'logout_confirmation': 'Are you sure you want to logout?',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      
      // Settings
      'general': 'General',
      'language': 'Language',
      'notifications': 'Notifications',
      'enabled': 'Enabled',
      'disabled': 'Disabled',
      'biometric_auth': 'Biometric Authentication',
      'biometric_auth_subtitle': 'Use fingerprint or Face ID',
      'security': 'Security',
      'two_factor_auth': 'Two-Factor Authentication',
      'two_factor_auth_subtitle': 'Add an extra layer of protection',
      'account': 'Account',
      'delete_account': 'Delete Account',
      'delete_account_subtitle': 'Permanently delete your account',
      'delete_account_confirmation': 'Are you sure you want to delete your account? This action cannot be undone.',
      'delete': 'Delete',
      'choose_language': 'Choose Language',
      'arabic': 'Arabic',
      'english': 'English',
      'language_changed_to': 'Language changed to',
      
      // My Properties
      'my_properties': 'My Properties',
      'add_property': 'Add Property',
      'edit': 'Edit',
      'share': 'Share',
      'delete_item': 'Delete',
      'property_details': 'Property Details',
      'edit_property': 'Edit Property',
      'share_property': 'Share',
      'delete_property': 'Delete',
      'property_description': 'Property Description',
      'tenant_data': 'Tenant Information',
      'rent_details': 'Rental Details',
      'monthly_rent_amount_label': 'Monthly rent:',
      'current_payment_status': 'Current payment status:',
      'next_due_date': 'Next due date:',
      'media_gallery': 'Photo & Video Gallery',
      'opening_image': 'Opening image',
      'opening_video': 'Opening video',
      'loading_pdf': 'Loading PDF...',
      'contract_ends_on': 'Contract ends on',
      'view_details_property': 'View details',
      'ready_for_immediate_rent': 'Ready for immediate rent',
      'opening_chat': 'Opening chat...',
      'bathrooms_count': '{count} bathrooms',
      'bedrooms_count': '{count} bedrooms',
      'area_display': '{area} m²',
      'contract_summary_property': 'Property: {name}',
      'contract_summary_tenant': 'Tenant: {name}',
      'contract_summary_rent': 'Rent amount: {amount} {currency}',
      'contract_summary_end_date': 'Contract end date: {date}',
      'contract_summary_next_due': 'Next due date: {date}',
      'contract_summary_status': 'Status: {status}',
      'no_contract_data_available': 'No contract data is available for this property yet.',
      'contract_pdf_server_note': 'The full PDF will be available once linked from the server.',
      
      // Common
      'save': 'Save',
      'save_image': 'Save Image',
      'delete_image': 'Delete Image',
      'choose_from_gallery': 'Choose from Gallery',
      'take_photo': 'Take Photo',
      'change_profile_picture': 'Change Profile Picture',
      
      // Dashboard
      'overview': 'Overview of your real estate investments',
      'total_balance': 'Total Collected Balance',
      'last_update': 'Last update: Today',
      'rented_properties': 'Rented Properties',
      'active_portfolio': 'Active Portfolio',
      'view_all': 'View All',
      'revenue_expense_report': 'Revenue and Expense Report',
      'revenue_expense_subtitle': 'Summary of rental activity and income for this month',
      'rented_properties_report': 'Rented Properties Report',
      'rented_properties_subtitle': 'Details of current properties and tenants',
      'construction_projects_report': 'Construction Projects Report',
      'construction_projects_subtitle': 'Complete details of projects and expected costs',
      'maps': 'Maps',
      'maps_subtitle': 'View all properties on the map',
      'ai_features': 'AI Features',
      'market_analysis': 'Market Analysis',
      'image_analysis': 'Image Analysis',
      'tenant_analysis': 'Tenant Analysis',
      'financial_predictions': 'Financial Predictions',
      
      // Profile
      'account_settings': 'Account Settings',
      'security_privacy': 'Security & Privacy',
      'privacy_policy': 'Privacy Policy',
      'privacy_section_1_title': '1. Information Collection',
      'privacy_section_1_content': 'We collect information you provide when using the app, including your name, email address, phone number, and property information.',
      'privacy_section_2_title': '2. Use of Information',
      'privacy_section_2_content': 'We use the information we collect to provide and improve our services, manage your account, and communicate with you about our services.',
      'privacy_section_3_title': '3. Information Protection',
      'privacy_section_3_content': 'We take reasonable security measures to protect your personal information from unauthorized access, alteration, disclosure, or destruction.',
      'privacy_section_4_title': '4. Information Sharing',
      'privacy_section_4_content': 'We do not sell or rent your personal information to third parties. We may share your information only in the cases specified in this policy.',
      'preferences': 'Preferences',
      'currency': 'Currency',
      'appearance': 'Appearance',
      'change_background_theme': 'Change background theme',
      'choose_app_appearance': 'Choose the app background appearance',
      'background_theme': 'Background theme',
      'theme_light': 'Light',
      'theme_dark': 'Dark',
      'theme_auto': 'Auto',
      'help': 'Help',
      'technical_support': 'Technical Support',
      
      // Property Status
      'rented': 'Rented',
      'vacant': 'Vacant',
      'tenant': 'Tenant',
      'no_tenant': 'No current tenant',
      'ready_for_rent': 'Ready for immediate rent',
      'contract_ends': 'Contract ends on',
      
      // Priority
      'urgent': 'Urgent',
      'medium': 'Medium',
      'normal': 'Normal',
      'high': 'High',
      'low': 'Low',
      
      // Edit Profile
      'full_name': 'Full Name',
      'enter_full_name': 'Enter your full name',
      'phone_number': 'Phone Number',
      'enter_phone': 'Enter phone number',
      'address': 'Address (Optional)',
      'enter_address': 'Enter address',
      'save_changes': 'Save Changes',
      'changes_saved': 'Changes saved successfully',
      'error_occurred': 'An error occurred',
      'signing_in': 'Signing in...',
      'demo_admin_account': 'Demo admin account',
      'demo_app_account': 'Demo app account',
      'fill_demo': 'Fill',
      'demo_login': 'Demo login',
      'enable_two_factor': 'Enable two-factor authentication',
      'enable_two_factor_desc': 'Enable 2FA for stronger account protection',
      'select_region_type': 'Select region and type',
      'analyze_market': 'Analyze market',
      'analyzing': 'Analyzing...',
      'real_estate_market_analysis': 'Real Estate Market Analysis',
      'two_factor_how': 'How does two-factor authentication work?',
      'two_factor_extra_layer': 'Extra protection layer',
      'two_factor_extra_layer_desc': 'After your password, you will need a verification code sent to your phone',
      'two_factor_breach': 'Protection against breaches',
      'two_factor_breach_desc': 'Even if someone knows your password, they cannot access your account',
      'two_factor_enabled_msg': 'Two-factor authentication enabled',
      'two_factor_disabled_msg': 'Two-factor authentication disabled',
      'commercial_shop': 'Commercial shop',
      'land_plot': 'Land',
      'abu_dhabi': 'Abu Dhabi',
      'image_selected': 'Image selected successfully',
      'image_captured': 'Image captured successfully',
      'image_deleted': 'Image deleted',
      'image_saved': 'Image saved successfully',
      'tap_to_change': 'Tap on image to change',
      'delete_current_image': 'Delete Current Image',
      
      // Change Password
      'current_password': 'Current Password',
      'new_password': 'New Password',
      'confirm_new_password': 'Confirm New Password',
      'enter_current_password': 'Please enter current password',
      'enter_new_password': 'Please enter new password',
      'password_changed': 'Password changed successfully',
      'change_password_subtitle': 'Enter your current and new password',
      'update_current_password': 'Update your current password',
      'update_personal_information': 'Update your personal information',
      
      // Home Shell
      'home': 'Home',
      'my_projects': 'My Projects',
      
      // Projects Screen
      'projects_under_construction': 'Projects Under Construction',
      'project_name': 'Project Name',
      'project_location': 'Location',
      'completion_rate': 'Completion Rate',
      'total_cost': 'Total Cost',
      'delivery_date': 'Delivery Date',
      'manager': 'Manager',
      'last_site_update': 'Last Site Update',
      'view_engineering_plans': 'View Engineering Plans',
      'view_3d_model': 'View 3D Model',
      'expected_completion_date': 'Expected Completion Date',
      'project_manager': 'Project Manager',
      'last_update_on': 'Last update: {date}',
      'days_ago_short': '{days} days ago',
      'sar': 'AED',
      'opening_edit_page': 'Opening edit page...',
      'sharing_property': 'Sharing property...',
      'property_deleted': 'Property deleted',
      
      // Contracts Screen
      'contracts_archive': 'Contracts Archive (with Management Options)',
      'extend_contract': 'Extend Contract',
      'file_lawsuit': 'File Lawsuit',
      'view_details': 'View Details',
      'contract_cancelled': 'Contract Cancelled',
      'cancel_contract': 'Cancel Contract',
      'cancel_contract_confirmation': 'Are you sure you want to cancel this contract?',
      'confirm_cancel_contract_title': 'Confirm Contract Cancellation',
      'cancel_contract_irreversible': 'Are you sure you want to cancel this contract? This action cannot be undone.',
      'cancel_reason': 'Cancellation Reason',
      'cancel_reason_contract_end': 'Contract term ended',
      'cancel_reason_tenant_violation': 'Tenant violation',
      'cancel_reason_tenant_request': 'Tenant request',
      'cancel_reason_other': 'Other reasons',
      'additional_details_optional': 'Additional details (optional)',
      'add_additional_details_hint': 'Add additional details...',
      'please_select_cancel_reason': 'Please select a cancellation reason',
      'lawsuit_type': 'Lawsuit Type',
      'lawsuit_type_rent_nonpayment': 'Non-payment of rent',
      'lawsuit_type_property_damage': 'Property damage',
      'lawsuit_type_contract_violation': 'Contract violation',
      'lawsuit_type_other': 'Other',
      'lawsuit_description': 'Lawsuit Description',
      'please_enter_lawsuit_description': 'Please enter lawsuit description',
      'lawsuit_description_hint': 'Enter lawsuit details...',
      'submit_lawsuit': 'Submit Lawsuit',
      'lawsuit_filed_success': 'Lawsuit filed successfully',
      'please_select_lawsuit_type': 'Please select a lawsuit type',
      'new_contract_end_date': 'New contract end date',
      'select_contract_end_date': 'Select contract end date',
      'extend_contract_notes_hint': 'Add notes about the contract extension...',
      'contract_extended_success': 'Contract extended successfully',
      'search_property_or_tenant': 'Search by property or tenant name',
      'active': 'Active',
      'expiring': 'Expiring Soon',
      'ended': 'Ended',
      'ends_in_days': 'Ends in {days} days',
      'ends_in_day': 'Ends in {days} day',
      'ended_days_ago': 'Ended {days} days ago',
      'tenant_label': 'Tenant: ',
      'end_date_label': 'End Date: ',
      
      // Services Screen
      'services_center': 'Services Center',
      'choose_service_you_need': 'Choose the service you need',
      'legal_consultations': 'Legal Consultations',
      'legal_consultations_subtitle': 'File a case, legal consultation, contract review',
      'legal_consultation': 'Legal Consultation',
      'engineering_consultations': 'Engineering Consultations',
      'engineering_consultations_subtitle': 'Request consultation, upload plans, property inspection',
      'engineering_consultation': 'Engineering Consultation',
      'maintenance': 'Maintenance',
      'maintenance_subtitle': 'Request repair, plumbing, electricity, painting',
      'repair_request': 'Repair Request',
      'repair_request_subtitle': 'Submit a new repair request',
      
      // Service Request Screen
      'service_request': 'Service Request',
      'error_selecting_images': 'Error selecting images',
      'problem_description': 'Problem Description',
      'problem_description_hint': 'Example: Weak cooling, water leak from internal unit...',
      'notes_optional': 'Write your notes here (optional)',
      'problem_details_required': 'Please write problem details here ....',
      'please_enter_problem_description': 'Please enter problem description',
      'choose_cleaning_type': 'Choose Cleaning Type',
      'deep_cleaning': 'Deep Cleaning',
      'periodic_cleaning': 'Periodic Cleaning',
      'attach_images': 'Attach Images',
      'attach_images_optional': 'Attach Images (optional)',
      'click_to_add_or_drag_images': 'Click to add or drag and drop images',
      'add_problem_images': 'Add problem images',
      'suitable_appointment': 'Suitable Appointment',
      'choose_day': 'Choose Day',
      'choose_time': 'Choose Time',
      'choose_date': 'Choose Date',
      'additional_notes': 'Additional Notes',
      'priority_level': 'Priority Level',
      'please_select_priority_level': 'Please select priority level',
      'please_select_cleaning_type': 'Please select cleaning type',
      'request_confirmed': 'Request Confirmed',
      'request_submitted': 'Request Submitted',
      'confirm_request': 'Confirm Request',
      'submit_request': 'Submit Request',
      'submit_new_request': 'Submit New Request',
      'problem_type': 'Problem Type',
      'select_problem_type': 'Select Problem Type',
      'please_select_problem_type': 'Please select problem type',
      'attach_photos': 'Attach Photos (optional)',
      'click_to_attach': 'Click to attach or drag images here',
      'previous_requests': 'My Previous Requests',
      'order_number': 'Order Number',
      'plumbing_problem': 'Plumbing Problem',
      'electricity_problem': 'Electricity Problem',
      'ac_problem': 'AC Problem',
      'cleaning_problem': 'Cleaning Problem',
      'other_problem': 'Other Problem',
      'kitchen_plumbing_problem': 'Kitchen Plumbing Problem',
      'request_submitted_successfully': 'Request submitted successfully',
      
      // Maintenance Screen
      'maintenance_services': 'Maintenance Services',
      'current_requests': 'Current Requests',
      'request_history': 'Request History',
      'choose_service_type': 'Choose Service Type',
      'electricity': 'Electricity',
      'electricity_subtitle': 'Malfunctions and Lighting',
      'plumbing': 'Plumbing',
      'plumbing_subtitle': 'Repairs and Leaks',
      'cleaning': 'Cleaning',
      'cleaning_subtitle': 'Periodic and Deep',
      'ac': 'AC',
      'ac_subtitle': 'Maintenance and Cooling',
      'in_progress': 'In Progress',
      'completed': 'Completed',
      'no_requests': 'No Requests',
      
      // Help Support Screen
      'help_support': 'Help & Support',
      'contact_us': 'Contact Us',
      'call_us': 'Call Us',
      'email_label': 'Email',
      'live_chat': 'Live Chat',
      'live_chat_subtitle': 'Available from 9 AM to 5 PM',
      'live_chat_coming_soon': 'Live chat will be available soon',
      'faq': 'Frequently Asked Questions',
      'faq_question_1': 'How do I add a new property?',
      'faq_answer_1': 'You can add a new property from the \'My Properties\' page and then click the add button.',
      'faq_question_2': 'How do I add a rental contract?',
      'faq_answer_2': 'Go to the \'Contracts\' page and click the \'+\' button to add a new contract.',
      'faq_question_3': 'How do I request maintenance service?',
      'faq_answer_3': 'From the \'Services\' page, select \'Maintenance\' and then choose the required service type.',
      'faq_question_4': 'How do I view financial reports?',
      'faq_answer_4': 'From the dashboard, click on \'Reports\' to view all financial reports.',
      
      // Search Screen
      'advanced_search': 'Advanced Search',
      'search_property': 'Search for property...',
      'filters': 'Filters',
      'property_type': 'Property Type',
      'all': 'All',
      'apartment': 'Apartment',
      'villa': 'Villa',
      'commercial': 'Commercial',
      'land': 'Land',
      'city': 'City',
      'riyadh': 'Riyadh',
      'jeddah': 'Jeddah',
      'dammam': 'Dammam',
      'madina': 'Madina',
      'price_range': 'Price Range (AED)',
      'from': 'From',
      'to': 'To',
      'area_range': 'Area (m²)',
      'search': 'Search',
      'results': 'Results',
      
      // Currency Settings Screen
      'usd': 'US Dollar',
      'aed': 'AED',
      'aed_currency': 'UAE Dirham',
      'sar_currency': 'Saudi Riyal',
      'sar_symbol': 'SAR',
      'eur': 'Euro',
      'gbp': 'British Pound',
      'currency_changed_to': 'Currency changed to',
      
      // Wallet Screen
      'wallet': 'Wallet',
      'financial_wallet': 'Financial Wallet',
      'filter_transactions': 'Filter Transactions',
      'revenues': 'Revenues',
      'expenses': 'Expenses',
      'this_month': 'This Month',
      'this_year': 'This Year',
      'total_expenses': 'Total Expenses',
      'monthly_income': 'Monthly Income',
      'bank_transfer_request': 'Bank Transfer Request',
      'bank_transfer_message': 'A bank transfer request will be sent to the bank. Do you want to proceed?',
      'active_tenant': 'Active Tenant',
      'total_monthly_rent': 'Total Monthly Rent',
      'proceed': 'Proceed',
      'transfer_request_sent': 'Transfer request sent successfully',
      'bank_transfer_account_selection': 'Select Account for Transfer',
      'account_type': 'Account Type',
      'my_current_account': 'My Current Account',
      'other_account': 'Another Account',
      'select_bank': 'Select Bank',
      'account_number': 'Account Number',
      'enter_account_number': 'Enter account number',
      'iban_optional': 'IBAN (optional)',
      'iban_hint': 'AE00 XXXX XXXX XXXX XXXX XXX',
      'account_holder_name': 'Account holder name',
      'enter_account_holder_name': 'Enter account holder name',
      'please_select_account_type': 'Please select account type',
      'please_enter_required_transfer_data': 'Please enter all required information',
      'other_bank': 'Other Bank',
      'filter': 'Filter',
      'transaction_log': 'Transaction Log',
      
      // Financial Predictions Screen
      'choose_period': 'Choose Period',
      'three_months': '3 Months',
      'six_months': '6 Months',
      'twelve_months': '12 Months',
      'generate_predictions': 'Generate Predictions',
      'revenue_forecast': 'Revenue Forecast',
      'for_next_period': 'For Next Period',
      'first_month': 'First Month',
      'second_month': 'Second Month',
      'third_month': 'Third Month',
      'expected_total': 'Expected Total',
      'expense_forecast': 'Expense Forecast',
      'expected_maintenance': 'Expected Maintenance',
      'taxes_fees': 'Taxes & Fees',
      'other_expenses': 'Other Expenses',
      'stable': 'Stable',
      'expected_net_profit': 'Expected Net Profit',
      'expected_growth': 'Expected Growth',
      'financial_recommendations': 'Financial Recommendations',
      'revenue_growth_recommendation': 'Revenue is growing steadily; consider investing in additional properties',
      'expense_stable_recommendation': 'Expenses are stable; allocate budget for preventive maintenance',
      'net_profit_positive_recommendation': 'Expected net profit is positive; a good opportunity to expand',

      // AI Assistant Screen
      'smart_assistant': 'Smart Assistant',
      'ai_welcome_message': 'Hello! I am your smart property management assistant. How can I help you today?',
      'quick_actions': 'Quick Actions',
      'write_rental_contract': 'Write Rental Contract',
      'write_property_ad': 'Write Property Ad',
      'analyze_property_performance': 'Analyze Property Performance',
      'maintenance_recommendations': 'Maintenance Recommendations',
      'estimate_rent_price': 'Estimate Rent Price',
      'advanced_features': 'Advanced Features',
      'write_message': 'Write your message...',
      'write_contract_prompt': 'Write a rental contract for me',
      'write_ad_prompt': 'Write a property listing ad',
      'analyze_performance_prompt': 'Analyze my property performance',
      'maintenance_recommendations_prompt': 'What are the maintenance recommendations?',
      'estimate_rent_prompt': 'Help me estimate the rent price',
      'ai_system_prompt': 'You are a smart assistant specialized in property management in the UAE and GCC. Reply clearly and helpfully in English.',
      'ai_sim_contract': 'I can help you draft a professional rental contract. Please provide:\n\n• Property name\n• Tenant name\n• Monthly rent amount\n• Contract duration (months)\n• Start date\n• Any additional terms\n\nI will then prepare a comprehensive contract aligned with local regulations.',
      'ai_sim_ad': 'I can write an attractive listing for your property. Please share:\n\n• Property type (apartment, villa, retail, etc.)\n• Detailed location\n• Area size\n• Bedrooms and bathrooms\n• Extra features (pool, garden, parking, etc.)\n• Rent price\n\nI will write a professional ad that highlights your property strengths.',
      'ai_sim_analysis': 'I can analyze your portfolio and provide a report including:\n\n📊 Key metrics:\n• Total monthly revenue\n• Occupancy rate\n• Average rent\n\n🏆 Top performers:\n• Most profitable properties\n• Lowest maintenance cost properties\n\n💡 Recommendations:\n• Yield improvement opportunities\n• Better management tips\n\nDo you want all properties analyzed or a specific one?',
      'ai_sim_maintenance': 'I can help you manage maintenance efficiently:\n\n🔧 Available services:\n• Schedule preventive maintenance\n• Track maintenance requests\n• Estimate costs\n• Suggest improvements\n• Image analysis to detect issues\n\n📅 Suggested schedule:\n• AC check: every 6 months (AED 500-800)\n• Plumbing check: every 3 months (AED 200-400)\n• Repainting: every 2-3 years (AED 5,000-15,000)\n• Safety check: monthly (AED 100-200)\n• Tank cleaning: every 6 months (AED 300-500)\n\n💡 Smart tips:\n• Preventive maintenance saves 30-40% of costs\n• Regular upkeep increases property value\n\nWhat issue are you facing now?',
      'ai_sim_valuation': 'I can help you set the right rent based on:\n\n📍 Key factors:\n• Location (district, nearby services)\n• Size and specifications\n• Property condition (new, old, renovated)\n• Market prices in the area\n• Extra amenities\n\n💰 Suggested range:\nBased on location and specs, I can estimate a suitable price range.\n\nShare the property details and I will suggest a fair rent.',
      'ai_sim_advice': 'I can provide advice on:\n\n💼 Property management:\n• Choosing the right tenants\n• Managing tenant relationships\n• Improving ROI\n\n🔧 Preventive maintenance:\n• Scheduling regular upkeep\n• Early issue detection\n• Reducing costs\n\n📈 Investment:\n• Opportunity analysis\n• Profitability assessment\n• Financial planning\n\nWhich topic would you like advice on?',
      'ai_sim_default': 'Thanks for your question! I am your smart property assistant. I can help with:\n\n📝 Writing:\n• Rental contracts\n• Property listings\n• Tenant messages\n\n📊 Analysis:\n• Financial performance\n• Market analysis\n• Detailed reports\n\n💡 Advice:\n• Better management tips\n• Improvement recommendations\n• Legal guidance\n\nWhat would you like help with?',

      // Calendar Screen
      'calendar': 'Calendar',
      'calendar_month': 'Month',
      'calendar_week': 'Week',
      'calendar_day': 'Day',
      'calendar_today': 'Today',
      'calendar_subtitle': 'Rent, maintenance and contract dates',
      'event_details': 'Event details',
      'go_to_related': 'Go to related section',
      'time': 'Time',
      'events': 'Events',
      'no_events_today': 'No events on this day',
      'january': 'January',
      'february': 'February',
      'march': 'March',
      'april': 'April',
      'may': 'May',
      'june': 'June',
      'july': 'July',
      'august': 'August',
      'september': 'September',
      'october': 'October',
      'november': 'November',
      'december': 'December',

      // Shared filters & labels
      'pending': 'Pending',
      'total_paid': 'Total Paid',
      'pending_payments': 'Pending Payments',
      'paid': 'Paid',
      'amount_label': 'Amount',
      'date_label': 'Date',
      'property_label': 'Property',
      'open_in_maps': 'Open in Maps',
      'maps_open_error': 'Cannot open maps. Make sure a maps app is installed',
      'maps_open_failed': 'Failed to open maps',
      'properties_on_map': 'Properties on map',
      'rent_amount_label': 'Rent amount',

      // Reports
      'filter_reports': 'Filter Reports',
      'select_report_type': 'Select report type',
      'loading_report': 'Loading report...',
      'revenue_expense_summary': 'Revenue & Expense Summary',
      'net_profit': 'Net Profit',
      'cash_flow_analysis': 'Cash Flow Analysis',
      'no_data_available': 'No data available',
      'load_more': 'Load more',
      'latest_transactions': 'Latest Transactions',
      'view_report': 'View Report',
      'report_period': 'Period',
      'report_created_on': 'Created on',
      'report_data': 'Data',
      'download_pdf': 'Download PDF',
      'report_total_income': 'Total Income',
      'report_transaction_count': 'Number of Transactions',
      'report_avg_monthly_income': 'Average Monthly Income',
      'report_total_properties': 'Total Properties',
      'report_vacant_properties': 'Vacant Properties',
      'report_active_projects': 'Active Projects',
      'report_avg_completion': 'Average Completion Rate',

      // Tenant analysis
      'government_employee': 'Government Employee',
      'private_employee': 'Private Employee',
      'freelancer': 'Freelancer',
      'retired': 'Retired',
      'employment_status': 'Employment Status',
      'has_previous_rental_record': 'Has previous rental record',
      'analyze_tenant_action': 'Analyze Tenant',
      'risk_score': 'Risk Score',
      'analysis_details': 'Analysis Details',
      'financial_capacity': 'Financial Capacity',
      'employment_stability': 'Employment Stability',
      'previous_record': 'Previous Record',
      'recommendation': 'Recommendation',
      'risk_high': 'High',
      'risk_medium': 'Medium',
      'risk_low': 'Low',
      'excellent': 'Excellent',
      'good': 'Good',
      'weak': 'Weak',
      'very_stable': 'Very Stable',
      'available': 'Available',
      'not_available': 'Not Available',
      'tenant_risk_high_recommendation': '⚠️ High risk: not recommended. Income may be insufficient or no rental history.',
      'tenant_risk_medium_recommendation': '⚠️ Medium risk: acceptable with extra conditions such as deposit or periodic review.',
      'tenant_risk_low_recommendation': '✅ Low risk: suitable tenant with sufficient income and stable employment.',

      // Image analysis
      'smart_image_analysis': 'Smart Image Analysis',
      'upload_property_image': 'Upload property image',
      'upload_multiple_images_hint': 'You can upload one or multiple images',
      'choose_image': 'Choose Image',
      'analysis_results': 'Analysis Results',
      'overall_rating': 'Overall Rating',
      'property_condition_good': 'Property condition is generally good',
      'maps_tap_hint': 'Tap any property in the list to open its location in maps',
      'properties_count': 'Properties',
      'avg_rent_price': 'Average rent price',
      'price_range_label': 'Price range',
      'minimum': 'Minimum',
      'average': 'Average',
      'maximum': 'Maximum',
      'market_trends': 'Market trends',
      'monthly_change': 'Monthly change',
      'yearly_change': 'Yearly change',
      'occupancy_rate': 'Occupancy rate',
      'market_rec_1': 'The market is growing steadily; consider raising rent by 5-10%',
      'market_rec_2': 'High demand in this area; a good investment opportunity',
      'market_rec_3': 'High occupancy rate; you can negotiate better terms',
      'per_month': 'mo',
      'recommendations_title': 'Recommendations',

      // Admin panel
      'property_admin': 'Property Admin',
      'admin_settings': 'Admin Settings',
      'admin_stack': 'Stack: Flutter + Laravel',
      'owners': 'Owners',
      'operations': 'Operations',
      'financial_admin': 'Financial',
      'users': 'Users',
      'retry': 'Retry',
      'demo_data_banner': 'Showing demo data — server unavailable',
      'web_only_action': 'This action is available on the web dashboard only',
      'settings_saved': 'Settings saved',
      'push_notifications_note': 'Notifications are loaded from the Laravel API — refresh from the notifications screen',
      'loading_properties': 'Loading properties...',
      'loading_contracts': 'Loading contracts...',
      'loading_tenants': 'Loading tenants...',
      'loading_wallet': 'Loading wallet...',
      'loading_dashboard': 'Loading dashboard...',
      'loading_reports': 'Loading reports...',
      'loading_notifications': 'Loading notifications...',
      'loading_projects': 'Loading projects...',
      'loading_maintenance': 'Loading maintenance requests...',
      'loading_maps': 'Loading map...',
      'loading_search': 'Searching...',
      'no_search_results': 'No matching results',
      'mark_all_read': 'Mark all as read',
      'not_found': 'Not found',
      'operation_successful': 'Operation successful',
      'operation_failed': 'Operation failed — check backend',
      'saved_successfully': 'Saved successfully',
      'save_failed': 'Save failed — check backend',
      'delete_failed': 'Delete failed',
      'add_owner': 'Add owner',
      'add_tenant': 'Add tenant',
      'add_contract': 'Add contract',
      'search_owners': 'Search owners...',
      'search_users': 'Search users...',
      'no_owners': 'No owners',
      'no_contracts': 'No contracts',
      'no_tenants': 'No tenants',
      'no_properties_found': 'No properties found',
      'no_notifications': 'No notifications',
      'notifications_filtered_empty': 'No notifications match your preferences — check notification settings',
      'no_reports': 'No reports',
      'no_payments': 'No payments',
      'no_transfers': 'No transfers',
      'joined': 'Joined',
      'balance': 'Balance',
      'delete_owner_title': 'Delete owner?',
      'delete_owner_message': 'This will remove the owner from the system.',
      'owner_profile': 'Owner Profile',
      'total_revenue_label': 'Total revenue',
      'join_date': 'Join date',
      'properties_count_label': 'Properties count',
      'owner_properties': 'Owner properties',
      'delete_contract_title': 'Delete contract?',
      'contract_details': 'Contract Details',
      'tenant_information': 'Tenant Information',
      'label_name': 'Name',
      'mobile_number': 'Mobile Number',
      'next_payment': 'Next Payment',
      'remaining_label': 'Remaining',
      'days_count': '{count} days',
      'view_pdf': 'View PDF',
      'renew_contract': 'Renew',
      'contract_rental_title': 'Rental Contract - {property}',
      'parties': 'Parties',
      'term_and_finances': 'Term & finances',
      'start_label': 'Start',
      'end_label': 'End',
      'deposit': 'Deposit',
      'delete_tenant_title': 'Delete tenant?',
      'tenant_details': 'Tenant Details',
      'rent_label': 'Rent',
      'delete_property_title': 'Delete property?',
      'basic_info': 'Basic info',
      'area_label': 'Area',
      'bedrooms': 'Bedrooms',
      'bathrooms': 'Bathrooms',
      'floor': 'Floor',
      'monthly_revenue': 'Monthly revenue',
      'description': 'Description',
      'edit_contract': 'Edit Contract',
      'edit_tenant': 'Edit Tenant',
      'edit_owner': 'Edit Owner',
      'property_name': 'Property name',
      'type_label': 'Type',
      'area_sqm': 'Area (m²)',
      'under_construction': 'Under construction',
      'properties_unit': 'properties',
      'users_unit': 'users',
      'unread': 'Unread',
      'maintenance_operations': 'Maintenance & Operations',
      'issue': 'Issue',
      'technician': 'Technician',
      'transfers': 'Transfers',
      'due_label': 'Due',
      'connected_to_api': 'Connected to Laravel API',
      'recent_activity': 'Recent Activity',
      'no_recent_activity': 'No recent activity from API',
      'open_maintenance': 'Open Maintenance',
      'active_contracts': 'Active Contracts',
      'this_week': 'This week',
      'admin_role': 'Admin',
      'admin_more': 'More',
      'analytics': 'Analytics',
      'tasks': 'Tasks',
      'messages': 'Messages',
      'registration_requests': 'Registration Requests',
      'add_user': 'Add user',
      'edit_user': 'Edit user',
      'delete_user_title': 'Delete user?',
      'delete_user_message': 'This will remove the user from the system.',
      'approve': 'Approve',
      'reject': 'Reject',
      'no_tasks': 'No tasks',
      'no_messages': 'No messages',
      'no_registration_requests': 'No registration requests',
      'financial_flow': 'Financial flow',
      'password_confirm': 'Confirm password',
      'revenue_chart': 'Monthly revenue',
      'occupancy_overview': 'Occupancy overview',
      'mobile_requests': 'Mobile requests',
      'role': 'Role',
      'required_field': 'Required',
      'none_option': '— None —',
      'start_date_format': 'Start date (YYYY-MM-DD)',
      'end_date_format': 'End date (YYYY-MM-DD)',
      'contract_start_format': 'Contract start (YYYY-MM-DD)',
      'contract_end_format': 'Contract end (YYYY-MM-DD)',
      'rent_amount': 'Rent amount',
      'owner': 'Owner',
      'overview_short': 'Overview',
      'sqm_unit': 'm²',
      'status_label': 'Status',
      'phone_short': 'Phone',
      'name_label': 'Name',
      'search_hint': 'Search...',
      'end_date_short': 'End',
      'contract_section': 'Contract',

      // Add Contract Screen
      'add_new_contract': 'Add New Contract',
      'contract_data': 'Contract Data',
      'select_property': 'Select Property',
      'please_select_property': 'Please select property',
      'contract_type': 'Contract Type',
      'monthly_rent': 'Monthly Rent',
      'annual_rent': 'Annual Rent',
      'temporary_rent': 'Temporary Rent',
      'please_select_contract_type': 'Please select contract type',
      'start_date': 'Start Date',
      'please_select_start_date': 'Please select start date',
      'end_date': 'End Date',
      'please_select_end_date': 'Please select end date',
      'tenant_name': 'Tenant Name',
      'tenant_enter_full_name': 'Enter full name',
      'please_enter_tenant_name': 'Please enter tenant name',
      'tenant_phone_number': 'Phone Number',
      'please_enter_phone_number': 'Please enter phone number',
      'monthly_rent_amount': 'Monthly Rent Amount',
      'please_enter_rent_amount': 'Please enter rent amount',
      'additional_notes_optional': 'Additional Notes (Optional)',
      'any_additional_notes': 'Any additional notes or conditions...',
      'contract_added_successfully': 'Contract added successfully',
      
      // Wallet Screen - Transaction Types
      'rent_unit_number': 'Rent Unit #',
      'rent_unit_101': 'Rent Unit #101',
      'rent_unit_205': 'Rent Unit #205',
      'maintenance_fees': 'Maintenance Fees',
      'profit_withdrawal': 'Profit Withdrawal',
      
      // Maintenance Screen
      'ac_repair': 'AC Repair',
      'kitchen_sink_leak': 'Kitchen Sink Leak',
      'ac_maintenance': 'AC Maintenance',
      'new_maintenance_request': 'New Maintenance Request',
      'request_number': 'Request #',
      // Contact Tenant Screen
      'contact_tenant_title': 'Contact Tenant',
      'contact_tenant_of': 'Tenant of {property}',
      'contact_via_whatsapp': 'Contact via WhatsApp',
      'phone_call': 'Phone Call',
      'contact_via_email': 'Send email',
      'contact_via_sms': 'Send SMS',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  // Getters for easier access
  String get appName => translate('app_name');
  String get welcomeSubtitle => translate('welcome_subtitle');
  String get splashLoading => translate('splash_loading');
  String get login => translate('login');
  String get loginSubtitle => translate('login_subtitle');
  String get email => translate('email');
  String get emailHint => translate('email_hint');
  String get password => translate('password');
  String get passwordHint => translate('password_hint');
  String get forgotPassword => translate('forgot_password');
  String get noAccount => translate('no_account');
  String get createAccount => translate('create_account');
  String get signUp => translate('sign_up');
  String get signUpSubtitle => translate('sign_up_subtitle');
  String get name => translate('name');
  String get nameHint => translate('name_hint');
  String get confirmPassword => translate('confirm_password');
  String get confirmPasswordHint => translate('confirm_password_hint');
  String get userType => translate('user_type');
  String get userTypeHint => translate('user_type_hint');
  String get userTypeTenant => translate('user_type_tenant');
  String get userTypeOwner => translate('user_type_owner');
  String get nationalId => translate('national_id');
  String get nationalIdHint => translate('national_id_hint');
  String get nationalIdRequired => translate('national_id_required');
  String get permissionsInfo => translate('permissions_info');
  String get tenantPermissions => translate('tenant_permissions');
  String get ownerPermissions => translate('owner_permissions');
  String get tenantPermissionsList => translate('tenant_permissions_list');
  String get ownerPermissionsList => translate('owner_permissions_list');
  String get note => translate('note');
  String get registrationNote => translate('registration_note');
  String get alreadyHaveAccount => translate('already_have_account');
  String get verification => translate('verification');
  String get verificationSubtitle => translate('verification_subtitle');
  String get verify => translate('verify');
  String get resendCode => translate('resend_code');
  String get codeRequired => translate('code_required');
  String get didntReceiveCode => translate('didnt_receive_code');
  String get forgotPasswordTitle => translate('forgot_password_title');
  String get forgotPasswordSubtitle => translate('forgot_password_subtitle');
  String get resetPassword => translate('reset_password');
  String get backToLogin => translate('back_to_login');
  String get resetLinkSent => translate('reset_link_sent');
  String get dashboard => translate('dashboard');
  String get welcome => translate('welcome');
  String get properties => translate('properties');
  String get tenants => translate('tenants');
  String get contracts => translate('contracts');
  String get payments => translate('payments');
  String get reports => translate('reports');
  String get services => translate('services');
  String get profile => translate('profile');
  String get editProfile => translate('edit_profile');
  String get changePassword => translate('change_password');
  String get settings => translate('settings');
  String get logout => translate('logout');
  String get logoutConfirmation => translate('logout_confirmation');
  String get cancel => translate('cancel');
  String get confirm => translate('confirm');
  String get general => translate('general');
  String get language => translate('language');
  String get notifications => translate('notifications');
  String get enabled => translate('enabled');
  String get disabled => translate('disabled');
  String get biometricAuth => translate('biometric_auth');
  String get biometricAuthSubtitle => translate('biometric_auth_subtitle');
  String get security => translate('security');
  String get twoFactorAuth => translate('two_factor_auth');
  String get twoFactorAuthSubtitle => translate('two_factor_auth_subtitle');
  String get account => translate('account');
  String get deleteAccount => translate('delete_account');
  String get deleteAccountSubtitle => translate('delete_account_subtitle');
  String get deleteAccountConfirmation => translate('delete_account_confirmation');
  String get delete => translate('delete');
  String get deleteItem => translate('delete_item');
  String get chooseLanguage => translate('choose_language');
  String get emailRequired => translate('email_required');
  String get emailInvalid => translate('email_invalid');
  String get nameRequired => translate('name_required');
  String get confirmPasswordRequired => translate('confirm_password_required');
  String get passwordsNotMatch => translate('passwords_not_match');
  String get passwordRequired => translate('password_required');
  String get passwordMinLength => translate('password_min_length');
  String get arabic => translate('arabic');
  String get english => translate('english');
  String get languageChangedTo => translate('language_changed_to');
  String get myProperties => translate('my_properties');
  String get addProperty => translate('add_property');
  String get edit => translate('edit');
  String get share => translate('share');
  String get propertyDetails => translate('property_details');
  String get save => translate('save');
  String get saveImage => translate('save_image');
  String get deleteImage => translate('delete_image');
  String get chooseFromGallery => translate('choose_from_gallery');
  String get takePhoto => translate('take_photo');
  String get changeProfilePicture => translate('change_profile_picture');
  
  // Dashboard
  String get overview => translate('overview');
  String get totalBalance => translate('total_balance');
  String get lastUpdate => translate('last_update');
  String get rentedProperties => translate('rented_properties');
  String get activePortfolio => translate('active_portfolio');
  String get viewAll => translate('view_all');
  String get filterProperties => translate('filter_properties');
  String get propertyStatus => translate('property_status');
  String get villa => translate('villa');
  String get apartment => translate('apartment');
  String get office => translate('office');
  String get riyadh => translate('riyadh');
  String get jeddah => translate('jeddah');
  String get dammam => translate('dammam');
  String get reset => translate('reset');
  String get applyFilter => translate('apply_filter');
  String get filterApplied => translate('filter_applied');
  String get location => translate('location');
  String get revenueExpenseReport => translate('revenue_expense_report');
  String get revenueExpenseSubtitle => translate('revenue_expense_subtitle');
  String get rentedPropertiesReport => translate('rented_properties_report');
  String get rentedPropertiesSubtitle => translate('rented_properties_subtitle');
  String get constructionProjectsReport => translate('construction_projects_report');
  String get constructionProjectsSubtitle => translate('construction_projects_subtitle');
  String get maps => translate('maps');
  String get mapsSubtitle => translate('maps_subtitle');
  String get aiFeatures => translate('ai_features');
  String get marketAnalysis => translate('market_analysis');
  String get imageAnalysis => translate('image_analysis');
  String get tenantAnalysis => translate('tenant_analysis');
  
  // Profile
  String get accountSettings => translate('account_settings');
  String get securityPrivacy => translate('security_privacy');
  String get privacyPolicy => translate('privacy_policy');
  String get privacySection1Title => translate('privacy_section_1_title');
  String get privacySection1Content => translate('privacy_section_1_content');
  String get privacySection2Title => translate('privacy_section_2_title');
  String get privacySection2Content => translate('privacy_section_2_content');
  String get privacySection3Title => translate('privacy_section_3_title');
  String get privacySection3Content => translate('privacy_section_3_content');
  String get privacySection4Title => translate('privacy_section_4_title');
  String get privacySection4Content => translate('privacy_section_4_content');
  String get preferences => translate('preferences');
  String get currency => translate('currency');
  String get appearance => translate('appearance');
  String get help => translate('help');
  String get technicalSupport => translate('technical_support');
  
  // Property Status
  String get rented => translate('rented');
  String get vacant => translate('vacant');
  String get tenant => translate('tenant');
  String get noTenant => translate('no_tenant');
  String get readyForRent => translate('ready_for_rent');
  String get contractEnds => translate('contract_ends');
  
  // Priority
  String get urgent => translate('urgent');
  String get medium => translate('medium');
  String get normal => translate('normal');
  String get high => translate('high');
  String get low => translate('low');
  
  // Edit Profile
  String get fullName => translate('full_name');
  String get enterFullName => translate('enter_full_name');
  String get phoneNumber => translate('phone_number');
  String get enterPhone => translate('enter_phone');
  String get address => translate('address');
  String get enterAddress => translate('enter_address');
  String get saveChanges => translate('save_changes');
  String get changesSaved => translate('changes_saved');
  String get errorOccurred => translate('error_occurred');
  String get signingIn => translate('signing_in');
  String get demoAdminAccount => translate('demo_admin_account');
  String get demoAppAccount => translate('demo_app_account');
  String get fillDemo => translate('fill_demo');
  String get demoLogin => translate('demo_login');
  String get enableTwoFactor => translate('enable_two_factor');
  String get enableTwoFactorDesc => translate('enable_two_factor_desc');
  String get selectRegionType => translate('select_region_type');
  String get analyzeMarket => translate('analyze_market');
  String get analyzing => translate('analyzing');
  String get realEstateMarketAnalysis => translate('real_estate_market_analysis');
  String get twoFactorHow => translate('two_factor_how');
  String get twoFactorExtraLayer => translate('two_factor_extra_layer');
  String get twoFactorExtraLayerDesc => translate('two_factor_extra_layer_desc');
  String get twoFactorBreach => translate('two_factor_breach');
  String get twoFactorBreachDesc => translate('two_factor_breach_desc');
  String get twoFactorEnabledMsg => translate('two_factor_enabled_msg');
  String get twoFactorDisabledMsg => translate('two_factor_disabled_msg');
  String get commercialShop => translate('commercial_shop');
  String get landPlot => translate('land_plot');
  String get abuDhabi => translate('abu_dhabi');
  String get imageSelected => translate('image_selected');
  String get imageCaptured => translate('image_captured');
  String get imageDeleted => translate('image_deleted');
  String get imageSaved => translate('image_saved');
  String get tapToChange => translate('tap_to_change');
  String get deleteCurrentImage => translate('delete_current_image');
  
  // Change Password
  String get currentPassword => translate('current_password');
  String get newPassword => translate('new_password');
  String get confirmNewPassword => translate('confirm_new_password');
  String get enterCurrentPassword => translate('enter_current_password');
  String get enterNewPassword => translate('enter_new_password');
  String get passwordChanged => translate('password_changed');
  String get changePasswordSubtitle => translate('change_password_subtitle');
  String get updateCurrentPassword => translate('update_current_password');
  String get updatePersonalInformation => translate('update_personal_information');
  
  // Home Shell
  String get home => translate('home');
  String get myProjects => translate('my_projects');
  
  // Projects Screen
  String get projectsUnderConstruction => translate('projects_under_construction');
  String get projectName => translate('project_name');
  String get projectLocation => translate('project_location');
  String get completionRate => translate('completion_rate');
  String get totalCost => translate('total_cost');
  String get deliveryDate => translate('delivery_date');
  String get manager => translate('manager');
  String get lastSiteUpdate => translate('last_site_update');
  String get viewEngineeringPlans => translate('view_engineering_plans');
  String get view3dModel => translate('view_3d_model');
  String get expectedCompletionDate => translate('expected_completion_date');
  String get projectManager => translate('project_manager');
  String lastUpdateOn(String date) =>
      translate('last_update_on').replaceAll('{date}', date);
  String daysAgoShort(int days) =>
      translate('days_ago_short').replaceAll('{days}', '$days');
  String get sar => translate('sar');
  String get openingEditPage => translate('opening_edit_page');
  String get sharingProperty => translate('sharing_property');
  String get propertyDeleted => translate('property_deleted');
  
  // Contracts Screen
  String get contractsArchive => translate('contracts_archive');
  String get extendContract => translate('extend_contract');
  String get fileLawsuit => translate('file_lawsuit');
  String get viewDetails => translate('view_details');
  String get contractCancelled => translate('contract_cancelled');
  String get cancelContract => translate('cancel_contract');
  String get cancelContractConfirmation => translate('cancel_contract_confirmation');
  String get confirmCancelContractTitle => translate('confirm_cancel_contract_title');
  String get cancelContractIrreversible => translate('cancel_contract_irreversible');
  String get cancelReason => translate('cancel_reason');
  String get cancelReasonContractEnd => translate('cancel_reason_contract_end');
  String get cancelReasonTenantViolation => translate('cancel_reason_tenant_violation');
  String get cancelReasonTenantRequest => translate('cancel_reason_tenant_request');
  String get cancelReasonOther => translate('cancel_reason_other');
  String get additionalDetailsOptional => translate('additional_details_optional');
  String get addAdditionalDetailsHint => translate('add_additional_details_hint');
  String get pleaseSelectCancelReason => translate('please_select_cancel_reason');
  String get lawsuitType => translate('lawsuit_type');
  String get lawsuitTypeRentNonpayment => translate('lawsuit_type_rent_nonpayment');
  String get lawsuitTypePropertyDamage => translate('lawsuit_type_property_damage');
  String get lawsuitTypeContractViolation => translate('lawsuit_type_contract_violation');
  String get lawsuitTypeOther => translate('lawsuit_type_other');
  String get lawsuitDescription => translate('lawsuit_description');
  String get pleaseEnterLawsuitDescription =>
      translate('please_enter_lawsuit_description');
  String get lawsuitDescriptionHint => translate('lawsuit_description_hint');
  String get submitLawsuit => translate('submit_lawsuit');
  String get lawsuitFiledSuccess => translate('lawsuit_filed_success');
  String get pleaseSelectLawsuitType => translate('please_select_lawsuit_type');
  String get newContractEndDate => translate('new_contract_end_date');
  String get selectContractEndDate => translate('select_contract_end_date');
  String get extendContractNotesHint => translate('extend_contract_notes_hint');
  String get contractExtendedSuccess => translate('contract_extended_success');
  String get searchPropertyOrTenant => translate('search_property_or_tenant');
  String get active => translate('active');
  String get expiring => translate('expiring');
  String get ended => translate('ended');
  String endsInDays(int days) => translate('ends_in_days').replaceAll('{days}', days.toString());
  String endsInDay(int days) => translate('ends_in_day').replaceAll('{days}', days.toString());
  String endedDaysAgo(int days) => translate('ended_days_ago').replaceAll('{days}', days.toString());
  String get tenantLabel => translate('tenant_label');
  String get endDateLabel => translate('end_date_label');
  
  // Services Screen
  String get servicesCenter => translate('services_center');
  String get chooseServiceYouNeed => translate('choose_service_you_need');
  String get legalConsultations => translate('legal_consultations');
  String get legalConsultationsSubtitle => translate('legal_consultations_subtitle');
  String get legalConsultation => translate('legal_consultation');
  String get engineeringConsultations => translate('engineering_consultations');
  String get engineeringConsultationsSubtitle => translate('engineering_consultations_subtitle');
  String get engineeringConsultation => translate('engineering_consultation');
  String get maintenance => translate('maintenance');
  String get maintenanceSubtitle => translate('maintenance_subtitle');
  String get repairRequest => translate('repair_request');
  String get repairRequestSubtitle => translate('repair_request_subtitle');
  
  // Service Request Screen
  String get serviceRequest => translate('service_request');
  String get errorSelectingImages => translate('error_selecting_images');
  String get problemDescription => translate('problem_description');
  String get problemDescriptionHint => translate('problem_description_hint');
  String get notesOptional => translate('notes_optional');
  String get problemDetailsRequired => translate('problem_details_required');
  String get pleaseEnterProblemDescription => translate('please_enter_problem_description');
  String get chooseCleaningType => translate('choose_cleaning_type');
  String get deepCleaning => translate('deep_cleaning');
  String get periodicCleaning => translate('periodic_cleaning');
  String get attachImages => translate('attach_images');
  String get attachImagesOptional => translate('attach_images_optional');
  String get clickToAddOrDragImages => translate('click_to_add_or_drag_images');
  String get addProblemImages => translate('add_problem_images');
  String get suitableAppointment => translate('suitable_appointment');
  String get chooseDay => translate('choose_day');
  String get chooseTime => translate('choose_time');
  String get chooseDate => translate('choose_date');
  String get additionalNotes => translate('additional_notes');
  String get priorityLevel => translate('priority_level');
  String get pleaseSelectPriorityLevel => translate('please_select_priority_level');
  String get pleaseSelectCleaningType => translate('please_select_cleaning_type');
  String get requestConfirmed => translate('request_confirmed');
  String get requestSubmitted => translate('request_submitted');
  String get confirmRequest => translate('confirm_request');
  String get submitRequest => translate('submit_request');
  String get submitNewRequest => translate('submit_new_request');
  String get problemType => translate('problem_type');
  String get selectProblemType => translate('select_problem_type');
  String get pleaseSelectProblemType => translate('please_select_problem_type');
  String get attachPhotos => translate('attach_photos');
  String get clickToAttach => translate('click_to_attach');
  String get previousRequests => translate('previous_requests');
  String get orderNumber => translate('order_number');
  String get plumbingProblem => translate('plumbing_problem');
  String get electricityProblem => translate('electricity_problem');
  String get acProblem => translate('ac_problem');
  String get cleaningProblem => translate('cleaning_problem');
  String get otherProblem => translate('other_problem');
  String get kitchenPlumbingProblem => translate('kitchen_plumbing_problem');
  String get requestSubmittedSuccessfully => translate('request_submitted_successfully');
  
  // Maintenance Screen
  String get maintenanceServices => translate('maintenance_services');
  String get currentRequests => translate('current_requests');
  String get requestHistory => translate('request_history');
  String get chooseServiceType => translate('choose_service_type');
  String get electricity => translate('electricity');
  String get electricitySubtitle => translate('electricity_subtitle');
  String get plumbing => translate('plumbing');
  String get plumbingSubtitle => translate('plumbing_subtitle');
  String get cleaning => translate('cleaning');
  String get cleaningSubtitle => translate('cleaning_subtitle');
  String get ac => translate('ac');
  String get acSubtitle => translate('ac_subtitle');
  String get inProgress => translate('in_progress');
  String get completed => translate('completed');
  String get noRequests => translate('no_requests');
  
  // Help Support Screen
  String get helpSupport => translate('help_support');
  String get contactUs => translate('contact_us');
  String get callUs => translate('call_us');
  String get emailLabel => translate('email_label');
  String get liveChat => translate('live_chat');
  String get liveChatSubtitle => translate('live_chat_subtitle');
  String get liveChatComingSoon => translate('live_chat_coming_soon');
  String get faq => translate('faq');
  String get faqQuestion1 => translate('faq_question_1');
  String get faqAnswer1 => translate('faq_answer_1');
  String get faqQuestion2 => translate('faq_question_2');
  String get faqAnswer2 => translate('faq_answer_2');
  String get faqQuestion3 => translate('faq_question_3');
  String get faqAnswer3 => translate('faq_answer_3');
  String get faqQuestion4 => translate('faq_question_4');
  String get faqAnswer4 => translate('faq_answer_4');
  
  // Search Screen
  String get advancedSearch => translate('advanced_search');
  String get searchProperty => translate('search_property');
  String get filters => translate('filters');
  String get propertyType => translate('property_type');
  String get all => translate('all');
  String get commercial => translate('commercial');
  String get land => translate('land');
  String get city => translate('city');
  String get madina => translate('madina');
  String get priceRange => translate('price_range');
  String get from => translate('from');
  String get to => translate('to');
  String get areaRange => translate('area_range');
  String get search => translate('search');
  String get results => translate('results');
  
  // Currency Settings Screen
  String get usd => translate('usd');
  String get aed => translate('aed');
  String get aedCurrency => translate('aed_currency');
  String get sarCurrency => translate('sar_currency');
  String get sarSymbol => translate('sar_symbol');
  String get eur => translate('eur');
  String get gbp => translate('gbp');
  String get currencyChangedTo => translate('currency_changed_to');
  
  // Wallet Screen
  String get wallet => translate('wallet');
  String get financialWallet => translate('financial_wallet');
  String get filterTransactions => translate('filter_transactions');
  String get revenues => translate('revenues');
  String get expenses => translate('expenses');
  String get thisMonth => translate('this_month');
  String get thisYear => translate('this_year');
  String get totalExpenses => translate('total_expenses');
  String get monthlyIncome => translate('monthly_income');
  String get bankTransferRequest => translate('bank_transfer_request');
  String get bankTransferMessage => translate('bank_transfer_message');
  String get activeTenant => translate('active_tenant');
  String get totalMonthlyRent => translate('total_monthly_rent');
  String get proceed => translate('proceed');
  String get transferRequestSent => translate('transfer_request_sent');
  String get bankTransferAccountSelection => translate('bank_transfer_account_selection');
  String get accountType => translate('account_type');
  String get myCurrentAccount => translate('my_current_account');
  String get otherAccount => translate('other_account');
  String get selectBank => translate('select_bank');
  String get accountNumber => translate('account_number');
  String get enterAccountNumber => translate('enter_account_number');
  String get ibanOptional => translate('iban_optional');
  String get ibanHint => translate('iban_hint');
  String get accountHolderName => translate('account_holder_name');
  String get enterAccountHolderName => translate('enter_account_holder_name');
  String get pleaseSelectAccountType => translate('please_select_account_type');
  String get pleaseEnterRequiredTransferData =>
      translate('please_enter_required_transfer_data');
  String get otherBank => translate('other_bank');
  String get filter => translate('filter');
  String get transactionLog => translate('transaction_log');
  
  // Financial Predictions Screen
  String get financialPredictions => translate('financial_predictions');
  String get choosePeriod => translate('choose_period');
  String get threeMonths => translate('three_months');
  String get sixMonths => translate('six_months');
  String get twelveMonths => translate('twelve_months');
  String get generatePredictions => translate('generate_predictions');
  String get revenueForecast => translate('revenue_forecast');
  String get forNextPeriod => translate('for_next_period');
  String get firstMonth => translate('first_month');
  String get secondMonth => translate('second_month');
  String get thirdMonth => translate('third_month');
  String get expectedTotal => translate('expected_total');
  String get expenseForecast => translate('expense_forecast');
  String get expectedMaintenance => translate('expected_maintenance');
  String get taxesFees => translate('taxes_fees');
  String get otherExpenses => translate('other_expenses');
  String get stable => translate('stable');
  String get expectedNetProfit => translate('expected_net_profit');
  String get expectedGrowth => translate('expected_growth');
  String get financialRecommendations => translate('financial_recommendations');
  String get revenueGrowthRecommendation => translate('revenue_growth_recommendation');
  String get expenseStableRecommendation => translate('expense_stable_recommendation');
  String get netProfitPositiveRecommendation => translate('net_profit_positive_recommendation');
  
  // AI Assistant Screen
  String get smartAssistant => translate('smart_assistant');
  String get aiWelcomeMessage => translate('ai_welcome_message');
  String get quickActions => translate('quick_actions');
  String get writeRentalContract => translate('write_rental_contract');
  String get writePropertyAd => translate('write_property_ad');
  String get analyzePropertyPerformance => translate('analyze_property_performance');
  String get maintenanceRecommendations => translate('maintenance_recommendations');
  String get estimateRentPrice => translate('estimate_rent_price');
  String get advancedFeatures => translate('advanced_features');
  String get writeMessage => translate('write_message');
  String get writeContractPrompt => translate('write_contract_prompt');
  String get writeAdPrompt => translate('write_ad_prompt');
  String get analyzePerformancePrompt => translate('analyze_performance_prompt');
  String get maintenanceRecommendationsPrompt => translate('maintenance_recommendations_prompt');
  String get estimateRentPrompt => translate('estimate_rent_prompt');
  String get aiSystemPrompt => translate('ai_system_prompt');
  String get aiSimContract => translate('ai_sim_contract');
  String get aiSimAd => translate('ai_sim_ad');
  String get aiSimAnalysis => translate('ai_sim_analysis');
  String get aiSimMaintenance => translate('ai_sim_maintenance');
  String get aiSimValuation => translate('ai_sim_valuation');
  String get aiSimAdvice => translate('ai_sim_advice');
  String get aiSimDefault => translate('ai_sim_default');
  String get changeBackgroundTheme => translate('change_background_theme');
  String get chooseAppAppearance => translate('choose_app_appearance');
  String get backgroundTheme => translate('background_theme');
  String get themeLight => translate('theme_light');
  String get themeDark => translate('theme_dark');
  String get themeAuto => translate('theme_auto');
  String get calendar => translate('calendar');
  String get calendarMonth => translate('calendar_month');
  String get calendarWeek => translate('calendar_week');
  String get calendarDay => translate('calendar_day');
  String get calendarToday => translate('calendar_today');
  String get calendarSubtitle => translate('calendar_subtitle');
  String get eventDetails => translate('event_details');
  String get goToRelated => translate('go_to_related');
  String get timeLabel => translate('time');
  String get events => translate('events');
  String get noEventsToday => translate('no_events_today');
  String get january => translate('january');
  String get february => translate('february');
  String get march => translate('march');
  String get april => translate('april');
  String get may => translate('may');
  String get june => translate('june');
  String get july => translate('july');
  String get august => translate('august');
  String get september => translate('september');
  String get october => translate('october');
  String get november => translate('november');
  String get december => translate('december');
  
  // Notification Settings Screen
  String get notificationSettings => translate('notification_settings');
  String get enableAllNotifications => translate('enable_all_notifications');
  String get enableAllNotificationsSubtitle => translate('enable_all_notifications_subtitle');
  String get rentReminders => translate('rent_reminders');
  String get rentRemindersSubtitle => translate('rent_reminders_subtitle');
  String get maintenanceAlerts => translate('maintenance_alerts');
  String get maintenanceAlertsSubtitle => translate('maintenance_alerts_subtitle');
  String get contractExpiry => translate('contract_expiry');
  String get contractExpirySubtitle => translate('contract_expiry_subtitle');
  String get paymentReminders => translate('payment_reminders');
  String get paymentRemindersSubtitle => translate('payment_reminders_subtitle');
  String get projectUpdates => translate('project_updates');
  String get projectUpdatesSubtitle => translate('project_updates_subtitle');
  String get marketingEmails => translate('marketing_emails');
  String get marketingEmailsSubtitle => translate('marketing_emails_subtitle');
  
  // Add Contract Screen
  String get addNewContract => translate('add_new_contract');
  String get contractData => translate('contract_data');
  String get selectProperty => translate('select_property');
  String get pleaseSelectProperty => translate('please_select_property');
  String get contractType => translate('contract_type');
  String get monthlyRent => translate('monthly_rent');
  String get annualRent => translate('annual_rent');
  String get temporaryRent => translate('temporary_rent');
  String get pleaseSelectContractType => translate('please_select_contract_type');
  String get startDate => translate('start_date');
  String get pleaseSelectStartDate => translate('please_select_start_date');
  String get endDate => translate('end_date');
  String get pleaseSelectEndDate => translate('please_select_end_date');
  String get tenantData => translate('tenant_data');
  String get tenantName => translate('tenant_name');
  String get tenantEnterFullName => translate('tenant_enter_full_name');
  String get pleaseEnterTenantName => translate('please_enter_tenant_name');
  String get tenantPhoneNumber => translate('tenant_phone_number');
  String get pleaseEnterPhoneNumber => translate('please_enter_phone_number');
  String get rentDetails => translate('rent_details');
  String get monthlyRentAmount => translate('monthly_rent_amount');
  String get pleaseEnterRentAmount => translate('please_enter_rent_amount');
  String get additionalNotesOptional => translate('additional_notes_optional');
  String get anyAdditionalNotes => translate('any_additional_notes');
  String get contractAddedSuccessfully => translate('contract_added_successfully');
  
  // My Properties Screen
  String get openingChat => translate('opening_chat');
  String get viewDetailsProperty => translate('view_details_property');
  String get tenantProperty => translate('tenant');
  String get contractEndsOn => translate('contract_ends_on');
  String get readyForImmediateRent => translate('ready_for_immediate_rent');
  
  // Property Detail Screen
  String get propertyDetailsScreen => translate('property_details');
  String get editProperty => translate('edit_property');
  String get shareProperty => translate('share_property');
  String get deleteProperty => translate('delete_property');
  String get sharingPropertyDetail => translate('sharing_property');
  String get propertyDeletedDetail => translate('property_deleted');
  String get propertyDescriptionDetail => translate('property_description');
  String get tenantDataProperty => translate('tenant_data');
  String get rentDetailsProperty => translate('rent_details');
  String get monthlyRentAmountLabel => translate('monthly_rent_amount_label');
  String get currentPaymentStatus => translate('current_payment_status');
  String get paidStatus => translate('paid');
  String get nextDueDateProperty => translate('next_due_date');
  String get mediaGallery => translate('media_gallery');
  String get openingImage => translate('opening_image');
  String get openingVideo => translate('opening_video');
  String get loadingPdf => translate('loading_pdf');
  String bathroomsCount(int count) =>
      translate('bathrooms_count').replaceAll('{count}', '$count');
  String bedroomsCount(int count) =>
      translate('bedrooms_count').replaceAll('{count}', '$count');
  String areaDisplay(String area) =>
      translate('area_display').replaceAll('{area}', area);
  String contractSummaryProperty(String name) =>
      translate('contract_summary_property').replaceAll('{name}', name);
  String contractSummaryTenant(String name) =>
      translate('contract_summary_tenant').replaceAll('{name}', name);
  String contractSummaryRent(String amount, String currency) => translate(
        'contract_summary_rent',
      ).replaceAll('{amount}', amount).replaceAll('{currency}', currency);
  String contractSummaryEndDate(String date) =>
      translate('contract_summary_end_date').replaceAll('{date}', date);
  String contractSummaryNextDue(String date) =>
      translate('contract_summary_next_due').replaceAll('{date}', date);
  String contractSummaryStatus(String status) =>
      translate('contract_summary_status').replaceAll('{status}', status);
  String get noContractDataAvailable => translate('no_contract_data_available');
  String get contractPdfServerNote => translate('contract_pdf_server_note');
  
  // Wallet Screen - Transaction Types
  String get rentUnitNumber => translate('rent_unit_number');
  String get rentUnit101 => translate('rent_unit_101');
  String get rentUnit205 => translate('rent_unit_205');
  String get maintenanceFees => translate('maintenance_fees');
  String get profitWithdrawal => translate('profit_withdrawal');
  
  // Maintenance Screen
  String get acRepair => translate('ac_repair');
  String get kitchenSinkLeak => translate('kitchen_sink_leak');
  String get acMaintenance => translate('ac_maintenance');
  String get newMaintenanceRequest => translate('new_maintenance_request');
  String get requestNumber => translate('request_number');
  String get contactTenantTitle => translate('contact_tenant_title');
  String contactTenantOf(String property) => translate('contact_tenant_of').replaceAll('{property}', property);
  String get contactViaWhatsapp => translate('contact_via_whatsapp');
  String get phoneCall => translate('phone_call');
  String get contactViaEmail => translate('contact_via_email');
  String get contactViaSms => translate('contact_via_sms');

  // Shared filters & extended screens
  String get pending => translate('pending');
  String get totalPaid => translate('total_paid');
  String get pendingPayments => translate('pending_payments');
  String get amountLabel => translate('amount_label');
  String get dateLabel => translate('date_label');
  String get propertyLabel => translate('property_label');
  String get openInMaps => translate('open_in_maps');
  String get mapsOpenError => translate('maps_open_error');
  String get mapsOpenFailed => translate('maps_open_failed');
  String get propertiesOnMap => translate('properties_on_map');
  String get rentAmountLabel => translate('rent_amount_label');
  String get filterReports => translate('filter_reports');
  String get selectReportType => translate('select_report_type');
  String get loadingReport => translate('loading_report');
  String get revenueExpenseSummary => translate('revenue_expense_summary');
  String get netProfit => translate('net_profit');
  String get cashFlowAnalysis => translate('cash_flow_analysis');
  String get noDataAvailable => translate('no_data_available');
  String get loadMore => translate('load_more');
  String get latestTransactions => translate('latest_transactions');
  String get viewReport => translate('view_report');
  String get reportPeriod => translate('report_period');
  String get reportCreatedOn => translate('report_created_on');
  String get reportData => translate('report_data');
  String get downloadPdf => translate('download_pdf');
  String get reportTotalIncome => translate('report_total_income');
  String get reportTransactionCount => translate('report_transaction_count');
  String get reportAvgMonthlyIncome => translate('report_avg_monthly_income');
  String get reportTotalProperties => translate('report_total_properties');
  String get reportVacantProperties => translate('report_vacant_properties');
  String get reportActiveProjects => translate('report_active_projects');
  String get reportAvgCompletion => translate('report_avg_completion');
  String get governmentEmployee => translate('government_employee');
  String get privateEmployee => translate('private_employee');
  String get freelancer => translate('freelancer');
  String get retired => translate('retired');
  String get employmentStatus => translate('employment_status');
  String get hasPreviousRentalRecord => translate('has_previous_rental_record');
  String get analyzeTenantAction => translate('analyze_tenant_action');
  String get riskScore => translate('risk_score');
  String get analysisDetails => translate('analysis_details');
  String get financialCapacity => translate('financial_capacity');
  String get employmentStability => translate('employment_stability');
  String get previousRecord => translate('previous_record');
  String get recommendation => translate('recommendation');
  String get riskHigh => translate('risk_high');
  String get riskMedium => translate('risk_medium');
  String get riskLow => translate('risk_low');
  String get excellent => translate('excellent');
  String get good => translate('good');
  String get weak => translate('weak');
  String get veryStable => translate('very_stable');
  String get available => translate('available');
  String get notAvailable => translate('not_available');
  String get tenantRiskHighRecommendation => translate('tenant_risk_high_recommendation');
  String get tenantRiskMediumRecommendation => translate('tenant_risk_medium_recommendation');
  String get tenantRiskLowRecommendation => translate('tenant_risk_low_recommendation');
  String get smartImageAnalysis => translate('smart_image_analysis');
  String get uploadPropertyImage => translate('upload_property_image');
  String get uploadMultipleImagesHint => translate('upload_multiple_images_hint');
  String get chooseImage => translate('choose_image');
  String get analysisResults => translate('analysis_results');
  String get overallRating => translate('overall_rating');
  String get propertyConditionGood => translate('property_condition_good');
  String get mapsTapHint => translate('maps_tap_hint');
  String get propertiesCount => translate('properties_count');
  String get avgRentPrice => translate('avg_rent_price');
  String get priceRangeLabel => translate('price_range_label');
  String get minimum => translate('minimum');
  String get average => translate('average');
  String get maximum => translate('maximum');
  String get marketTrends => translate('market_trends');
  String get monthlyChange => translate('monthly_change');
  String get yearlyChange => translate('yearly_change');
  String get occupancyRate => translate('occupancy_rate');
  String get marketRec1 => translate('market_rec_1');
  String get marketRec2 => translate('market_rec_2');
  String get marketRec3 => translate('market_rec_3');
  String get perMonth => translate('per_month');
  String get recommendationsTitle => translate('recommendations_title');

  // Admin panel
  String get propertyAdmin => translate('property_admin');
  String get adminSettings => translate('admin_settings');
  String get adminStack => translate('admin_stack');
  String get owners => translate('owners');
  String get operations => translate('operations');
  String get financialAdmin => translate('financial_admin');
  String get users => translate('users');
  String get retry => translate('retry');
  String get demoDataBanner => translate('demo_data_banner');
  String get webOnlyAction => translate('web_only_action');
  String get settingsSaved => translate('settings_saved');
  String get pushNotificationsNote => translate('push_notifications_note');
  String get loadingProperties => translate('loading_properties');
  String get loadingContracts => translate('loading_contracts');
  String get loadingTenants => translate('loading_tenants');
  String get loadingWallet => translate('loading_wallet');
  String get loadingDashboard => translate('loading_dashboard');
  String get loadingReports => translate('loading_reports');
  String get loadingNotifications => translate('loading_notifications');
  String get loadingProjects => translate('loading_projects');
  String get loadingMaintenance => translate('loading_maintenance');
  String get loadingMaps => translate('loading_maps');
  String get loadingSearch => translate('loading_search');
  String get noSearchResults => translate('no_search_results');
  String get markAllRead => translate('mark_all_read');
  String get notFound => translate('not_found');
  String get operationSuccessful => translate('operation_successful');
  String get operationFailed => translate('operation_failed');
  String get savedSuccessfully => translate('saved_successfully');
  String get saveFailed => translate('save_failed');
  String get deleteFailed => translate('delete_failed');
  String get addOwner => translate('add_owner');
  String get addTenant => translate('add_tenant');
  String get addContract => translate('add_contract');
  String get searchOwners => translate('search_owners');
  String get searchUsers => translate('search_users');
  String get noOwners => translate('no_owners');
  String get noContracts => translate('no_contracts');
  String get noTenants => translate('no_tenants');
  String get noPropertiesFound => translate('no_properties_found');
  String get noNotifications => translate('no_notifications');
  String get notificationsFilteredEmpty => translate('notifications_filtered_empty');
  String get noReports => translate('no_reports');
  String get noPayments => translate('no_payments');
  String get noTransfers => translate('no_transfers');
  String get joined => translate('joined');
  String get balance => translate('balance');
  String get deleteOwnerTitle => translate('delete_owner_title');
  String get deleteOwnerMessage => translate('delete_owner_message');
  String get ownerProfile => translate('owner_profile');
  String get totalRevenueLabel => translate('total_revenue_label');
  String get joinDate => translate('join_date');
  String get propertiesCountLabel => translate('properties_count_label');
  String get ownerProperties => translate('owner_properties');
  String get deleteContractTitle => translate('delete_contract_title');
  String get contractDetails => translate('contract_details');
  String get tenantInformation => translate('tenant_information');
  String get labelName => translate('label_name');
  String get mobileNumber => translate('mobile_number');
  String get nextPayment => translate('next_payment');
  String get remainingLabel => translate('remaining_label');
  String daysCount(int count) =>
      translate('days_count').replaceAll('{count}', '$count');
  String get viewPdf => translate('view_pdf');
  String get renewContract => translate('renew_contract');
  String contractRentalTitle(String property) =>
      translate('contract_rental_title').replaceAll('{property}', property);
  String get parties => translate('parties');
  String get termAndFinances => translate('term_and_finances');
  String get startLabel => translate('start_label');
  String get endLabel => translate('end_label');
  String get deposit => translate('deposit');
  String get deleteTenantTitle => translate('delete_tenant_title');
  String get tenantDetails => translate('tenant_details');
  String get rentLabel => translate('rent_label');
  String get deletePropertyTitle => translate('delete_property_title');
  String get basicInfo => translate('basic_info');
  String get areaLabel => translate('area_label');
  String get bedrooms => translate('bedrooms');
  String get bathrooms => translate('bathrooms');
  String get floor => translate('floor');
  String get monthlyRevenue => translate('monthly_revenue');
  String get description => translate('description');
  String get editContract => translate('edit_contract');
  String get editTenant => translate('edit_tenant');
  String get editOwner => translate('edit_owner');
  String get propertyName => translate('property_name');
  String get typeLabel => translate('type_label');
  String get areaSqm => translate('area_sqm');
  String get underConstruction => translate('under_construction');
  String get propertiesUnit => translate('properties_unit');
  String get usersUnit => translate('users_unit');
  String get unread => translate('unread');
  String get maintenanceOperations => translate('maintenance_operations');
  String get issue => translate('issue');
  String get technician => translate('technician');
  String get transfers => translate('transfers');
  String get dueLabel => translate('due_label');
  String get connectedToApi => translate('connected_to_api');
  String get recentActivity => translate('recent_activity');
  String get noRecentActivity => translate('no_recent_activity');
  String get openMaintenance => translate('open_maintenance');
  String get activeContracts => translate('active_contracts');
  String get thisWeek => translate('this_week');
  String get adminRole => translate('admin_role');
  String get adminMore => translate('admin_more');
  String get analytics => translate('analytics');
  String get tasks => translate('tasks');
  String get messages => translate('messages');
  String get registrationRequests => translate('registration_requests');
  String get addUser => translate('add_user');
  String get editUser => translate('edit_user');
  String get deleteUserTitle => translate('delete_user_title');
  String get deleteUserMessage => translate('delete_user_message');
  String get approve => translate('approve');
  String get reject => translate('reject');
  String get noTasks => translate('no_tasks');
  String get noMessages => translate('no_messages');
  String get noRegistrationRequests => translate('no_registration_requests');
  String get financialFlow => translate('financial_flow');
  String get passwordConfirm => translate('password_confirm');
  String get revenueChart => translate('revenue_chart');
  String get occupancyOverview => translate('occupancy_overview');
  String get mobileRequests => translate('mobile_requests');
  String get role => translate('role');
  String get requiredField => translate('required_field');
  String get noneOption => translate('none_option');
  String get startDateFormat => translate('start_date_format');
  String get endDateFormat => translate('end_date_format');
  String get contractStartFormat => translate('contract_start_format');
  String get contractEndFormat => translate('contract_end_format');
  String get rentAmount => translate('rent_amount');
  String get owner => translate('owner');
  String get overviewShort => translate('overview_short');
  String get sqmUnit => translate('sqm_unit');
  String get statusLabel => translate('status_label');
  String get phoneShort => translate('phone_short');
  String get nameLabel => translate('name_label');
  String get searchHint => translate('search_hint');
  String get endDateShort => translate('end_date_short');
  String get contractSection => translate('contract_section');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['ar', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

