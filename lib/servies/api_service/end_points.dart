//base url
class EndPoints {
  static const String oldUrl =
      "https://l5v2vkz7anwwoy5nu6unyquzmy0axuet.lambda-url.ap-south-1.on.aws/api/";
  static const String baseUrl =
      "http://app-load-balancer-snageasy-2052419147.ap-south-1.elb.amazonaws.com/Snageasy/v1/api/";
  static const String baseUrl2 =
      "http://app-load-balancer-snageasy-2052419147.ap-south-1.elb.amazonaws.com/";
  // receiveTimeout
  static const int receiveTimeout = 15000;

  // connectTimeout
  static const int connectionTimeout = 15000;

  static const usernameLogin = "Auth/login";
  static const otpLogin = "comms-layer/sms/snageasy/otp-login";
  static const otpSignUp = "comms-layer/sms/snageasy/otp-signup";
  static const verifyOTP = "comms-layer/verify-otp";
  static const getOrderkyc = "Order/Getorderkyc";

  static const bannerImage = "Appmedia/GetImages/1?type=snageasy-home-banner";
  static const getAllProducts = "Products/GetAllProducts";
  static const getPackagedetails = "Products/GetPackagedetails";
  static const getServicedetails = "Products/GetServicedetails";
  static const getCartValue = "Cart/Getcartvalue";
  static const createCart = "Order/Creatcart";
  static const updateKYC = "Order/UpdateKYC";
  static const getOrderLocation = "Order/GetOrderLocation";
  static const updateLocatoin = "Order/UpdateLocation";
  static const getBookingSummery = "Order/Getbookingsummary";
  static const confirmOrder = "Order/Confirmorder";
  static const getAppartmentType = "Location/Getapartments";
  static const addCustomer = "Account/Customermaster?type=ADD";
  static const upateCustomer = "Account/Customermaster?type=UPDATE";
  static const getCustomer = "Account/Getcustomer?mobileno=";
  static const getAllServiceType = "Products/Getactiveservices";
  static const getOrderDetails = "Account/Orderdetails";
  static const getWalletDetails = "Account/Getwalletdetails";
  static const getUploadedMedia = "AmazonS3/Getbucketfiles";
  static const uploadedMedia = "AmazonS3/UploadDocumentToS3";
  static const referAFriend = "Order/Referredby";
  static const getfeebackparams = "Socialconnect/Getfeebackparams";
  static const postcustomerfeedback = "Socialconnect/Postcustomerfeedback";
  static const getFAQ = "Socialconnect/Getfaqs";
  static const getpropertymedia =
      "Appmedia/Getpropertymedia?servicetype=Home%20Inspection";
  static const getCoverage = "Services/Checkserviceability";
  static const socialMediaLink = "comms-layer/socialconnect/medias";
  static const callAppointment =
      "comms-layer/calls/dail?source=snageasy-customer-direct";
  static const testimonial = "comms-layer/socialconnect/testimonials";
  static const getServiceType = "Services/Getservicetypes";
  static const aboutUs =
      "service-layer/snageasy?app=snageasy-customer-app&topictype=about-us";
  static const usp = "service-layer/usp?app=snageasy-customer-app";
  static const getServices =
      "service-layer/snageasy?app=snageasy-customer-app&topictype=core-services&topic=all";
  static const processFlowImage =
      "Appmedia/GetImages/1?type=snageasy-process-flow";
  static const myOrders = "Account/Myorders";
  static const sampleReport = "service-layer/snageasy";
  static const walletBalance = "Account/Getwalletbalance";
  static const onSiteInspection = "service-layer/snageasy/on-site-view";
  static const getReasonMaster = "account/GetReasonMaster";
  static const deleteAccount = "account/DeleteAccount";
}
