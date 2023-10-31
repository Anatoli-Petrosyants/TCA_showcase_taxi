//
//  MapViewRepresentable.swift
//  Taxi
//
//  Created by Anatoli Petrosyants on 11.10.23.
//

import SwiftUI
import GoogleMaps
import CoreLocation

extension GMSCameraPosition {
    static let `default` = GMSCameraPosition.camera(withLatitude: 40.18397482, longitude: 44.51509883, zoom: 18.0)
}

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
    
    static func != (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude != rhs.latitude && lhs.longitude != rhs.longitude
    }
}

let cameraTopPadding: CGFloat = 110.0

struct GoogleMapViewRepresentable: UIViewRepresentable {
    
    typealias UIViewType = GMSMapView
    
    var userLocation: CLLocation?
    var points: [String]?
    var mapViewIdleAtPosition: (GMSCameraPosition) -> ()
    var mapViewWillMove: (Bool) -> ()

    init(userLocation: CLLocation?,
         points: [String]?,
         mapViewIdleAtPosition: @escaping (GMSCameraPosition) -> Void,
         mapViewWillMove: @escaping (Bool) -> Void) {
        // Log.info("GoogleMapViewRepresentable init userLocation \(String(describing: userLocation))")
        
        self.userLocation = userLocation
        self.points = points
        self.mapViewIdleAtPosition = mapViewIdleAtPosition
        self.mapViewWillMove = mapViewWillMove
    }
    
    func makeUIView(context: Self.Context) -> UIViewType {
        // Log.info("GoogleMapViewRepresentable makeUIView \(String(describing: userLocation))")
        
        let mapView = GMSMapView.map(withFrame: .zero, camera: .default)
        mapView.isMyLocationEnabled = true
        mapView.isBuildingsEnabled = true
        mapView.mapType = .normal
        mapView.settings.rotateGestures = false
        mapView.settings.tiltGestures = false
        // mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: cameraTopPadding, right: 0)
        mapView.delegate = context.coordinator
        
        do {
          if let styleURL = Bundle.main.url(forResource: "map_style", withExtension: "json") {
              mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
          } else {
              Log.error("Unable to find style.json")
          }
        } catch {
            Log.error("One or more of the map styles failed to load. \(error)")
        }
        
        return mapView
    }
    
    func updateUIView(_ mapView: UIViewType , context: Self.Context) {
        if let location = userLocation {
            mapView.animate(toLocation: location.coordinate)
        }
        
        if let points = points, points.count > 0 {
            for point in points {
                let path = GMSPath(fromEncodedPath: point)
                let polyline = GMSPolyline(path: path)
                polyline.strokeColor = .white
                polyline.strokeWidth = 2.0
                polyline.map = mapView
            }
        }
        
//        let paths = ["s`htFskunGMMw@y@aAkAmA}AmA_Bu@}@a@g@iB_CaBuBGIg@o@KUGYAU",
//                     "auhtFaevnGAG?Q@IDUHa@Ni@\\oAPo@DQj@}ARg@jA_D",
//                     "_nhtF_wvnGOQqB}BuAaBQU{@eAKM_AmA{AiBk@u@EUCO@QLe@JW@EDS@QBY@W@a@?Q?K?eAAaAAkB",
//                     "y|htFqywnGJ@B?DABADABAFE@A?A@A@CBA@C?C@A@C@C?C@G@G?I?GAGAICGAEEGEGIGAAA?AAA?A?AAA?IkAGiBCeA?GCsA?ICUASAOAAESEMCE]q@]k@Sa@EKGQIUGWCYAQAUQoAGe@Y_Be@sAS_@SYS]u@}@GIuAeBcBuBYc@QUS]Ye@Wm@Qq@G_@CMCKGy@Cm@AU?OTaD@C@Q\\iDJ{@DYTmBP{ALsABa@BSBa@FcB@oA@I?yAAu@IoAIy@?EKaACO?CI_@O}@WuA[mA[eAAASm@GOUi@Ui@[m@gDuFkCiEs@_AU[e@o@QSW[s@{@}AqBOSu@_A{@eAo@u@GIk@u@Y_@uBiCq@w@iAqA_@]QSc@a@_@_@mAiAcAaAsDqDcEcEkFcF][QQu@q@k@g@a@]YWKIs@c@}@k@gAo@YKs@[}Aq@{Bu@a@Oy@YcA]kBo@uCeAiBm@oBq@WKs@Ws@S{@Sg@K}@Gu@GM?y@?cABs@BSDKNM@E@C?E@C@E?C@E?C@E?C@E?C@E@C?E@C?E@C@C?E@C@E?C@E?C@E@C?E@C?E@C@E?C@E?C@E?C@E?C@E@C?E@C?E@C?C@E?C@E?C@E?C@E@C?E@C?E@C@E?C@E?C@E@C?E@C?E@C?E@C?E@C?E@C?E@C?C@E?C@E?C@E?E@E?C@E?C@E?C@E?C@E?C@E?C@E?C@E?C@C?eC\\{@JaALi@H[DgBTQBqAPw@Jg@Hi@Ju@Pw@Rm@Pk@Ro@T}@`@u@^s@^{@d@s@^q@^oAp@EBoAp@uAt@qAr@e@V_@RaAh@c@T]Ni@TWHUHa@L]HQBa@Hs@Hk@F_@Bg@@m@@A?w@AwAEkBEgAEmACYCc@CC?a@Gk@Iy@OCAm@QUI_@MAAa@Oi@WQKaAi@g@o@g@a@m@i@aAcAqDuDAAg@i@kCsCw@{@]]OOY_@[]c@g@g@o@e@q@IMm@eAg@cAi@iAm@wASg@i@}AEKy@_CGQiAaDe@oAkAgDg@uAyAcEa@gAc@qAaCyGqCqHUo@cAsCO_@Oc@c@iAUo@kBwEYu@sGiPaBcEqAcDSe@}@_Ci@mAUo@k@{Ae@gAc@_Ae@aAo@gAs@aAw@cAw@}@A?m@o@[W]YMIOKMIKIOKOKiEyCiBsAuAgAyAsAm@g@{C}CMMWYIMaAkAyAkB]a@s@cAeAaBQWGM{@uAg@{@eAoB_AoBUa@AE[k@c@y@o@oAg@_Ac@u@a@m@EICE]g@i@u@AAk@s@c@c@]]CCKKu@o@u@m@WUECQOgAq@]SeAk@uAq@GCEAiDiA}@UA?EA]IUEo@K}@MMA_AIAAeAE}@AK?EAE?{A@kA@E?A?mA@A?S?aBBm@@E?e@@eAB]@kCDsB@C?mCBaBBA?E?u@?y@A_ACs@Cu@GE?E?wAKuAQ_AK?AE?qAUsASCAEAcB]IC{@QCAs@OqBi@A?sA_@SEECqA]OEg@Q[KWKqC_AyAk@KEa@Oa@Q}Aq@e@W]QA?gBaAYOmAq@k@]EEa@U]Ua@WsBqAg@[a@WsA{@gC_BAAA?qCeBeC}AiGyDiAw@gBgAgAq@kBgAs@c@u@c@{@k@}@k@[Sg@[yBsAoAw@MGa@WyBuAUMKIgAq@IGyBsA]UyBuAqBoAsAy@cDsBa@WQKQMKGkC_ByA}@sK}G_@U}E}C}AaA}CqB}E}C}GcE}EyCa@U}@k@mN{IMI}GgE_@Uq@a@kEmC}BwAaAm@]UAAoCiBkBqAeEaDaDgCa@]eA}@cDsCoDaDsAkA{BqBy@u@[Y}EmEgB}AiEuD}AuAwAqAqCeC][iD{CgB}A{@o@WQ_@Wy@i@eAk@}A{@y@_@mAe@yAi@aAUaAIy@AG?[?c@?W?wBD}AHsANmAN_@Hm@H}A^gBb@i@PMDMDoA^{ExAA?_D`AiCv@UHc@L}Br@wAb@iDv@E@y@NiB\\UBmBZ{@LcANsAR}F~@{Er@{ATc@FaC^aDf@}Cd@_JpAOBE@EBKHUTMDG@m@FuAPy@JWB[DsC\\UBuAPUBwBV_CXaBP}B\\qAXw@Pg@Lm@NIBe@JIBaATuBh@y@JA?c@Bk@@g@Cg@Ei@KKEWIe@Qe@UKIYSc@_@OQKKY_@e@y@GOO_@M_@AGSo@Ms@Ko@I{@K}@Kw@Iq@My@Ms@Oq@Sm@Um@Q]]i@_@c@II[Yc@]YQg@Ue@Qc@Kc@EC?A?QAWAwAEsBIk@Ec@Ge@KGCc@Mk@Ye@_@_@_@_@g@AAUa@IMa@_AW{@c@iB?AI{@C{@CsECqBCm@Go@Kq@[qAGUIYc@}@i@{@KMOOGI?AECi@e@AA_@Ue@S{@Wy@Sq@O}@SsAY}@Sa@IyA[OCKC]KGCKEc@Uk@a@[[a@e@[e@c@y@a@cAKW}@cCkAcD]}@yBgGw@sB[o@Wa@k@u@a@c@m@g@g@[[M}@]k@Ii@Gu@?y@Fm@J{@R{Bf@kB^[Bi@@sACq@E_@EaAUs@U?As@Y}A_AgEgC}E{CeEeCA?qJ}FkC}AsAy@KGgFyCsDeCeBkAu@k@sB}ACEA?mBiBCE_C{BwCaDmCwC?AA?aEmEw@y@i@k@{CcD?AY[cAkAoBoBQSY[[][]yBeCQSYY{@aAeBiBcCiCeBiBUW]_@gAoAyBaCaCeCeDqDgDqDk@m@WY[[q@u@g@g@UWs@w@i@k@sAaBk@s@[c@QQq@}@kC{Co@q@o@s@OOs@s@q@s@gBgBs@s@OQIIIIwAsAaAaAqAyAaEsE[]eBoBqEwFsEeGGKoDkFs@cAkAcBq@aAq@cAwCiEq@cAi@w@gAcBIMGIi@y@cBiCWa@mAiBmBwCaDqEqDqFcBgCq@cAmAgBU]mHwKAAaBcCcBgCiAeBCCmDgF{FoIqDkF[e@m@}@yAkBiAmAs@m@uBaBkBiAyC_BkDeBaAg@_@Se@SaD_B_Bw@eD}AcD}AaAe@kLwFeD_BcEsBcDcB{CyAiCsAcCkAc@U}@c@cCmAcEqBCA_Bw@aCmAkDaB_@Sy@a@gD}A{CyBwAs@eAm@wDyBcDyBkAw@kE}CIGUOwCuBqEeDqEaDmA}@oA}@aFoD_As@kCkBsDmC}CyBoEeDeEyCgBqAwAcA_D{BQKMKyCyBkBsAmA{@[Wm@g@q@o@q@u@c@m@_@e@m@{@c@w@m@kAkAiCMYeAaCi@kAuByEsCoGKWiBeEeB{Dg@iAkCcG_@y@}@uBe@eAo@{A_AwB}@oB{BeFa@_A[s@a@}@m@oAi@eA]s@Ue@MWsAkCc@y@m@gAQ][k@wAkCyAqC_BwCcAmBSa@oBuDyBeEeBcDqAeCuB}DGOuAiC}@eBmA}Bk@gAIOcBaDUc@S]eBeDu@uAq@uAuAkCyBeECEiBmDyBcEeAsBS_@Sa@e@{@mA_C_HoMaB_Dw@uAo@mAOW[i@Q[]k@kBaDyBsDuC{E{CaFy@uA_BkCOUgDqFa@q@Wc@{BsDkD{FaA_B}EcIaC{DwE_Iy@qAmB_DiByCKOKSq@eAa@q@kBaDCC}DuGAC{CcFiCgEq@oAQ]CEw@yAcAoBwBiEyFeLiBqDeAuBcCaFqE_JaDsGyDyHuDkH{A}Ck@iAq@{As@gBy@wB_EoK{C}HuBmF{EcMcBqEo@_BgCwGcAmCq@iBmBaFQa@uBsFEKsCsHIUcDoIYu@_@iA[aA]kA]oA_@_BoA{FgCsL_BsHMk@YoAwAoGkByIKg@ACeCkLy@wDk@iCkAoFaBwH}CwNI]_AiE{@_Ei@cCUeAsBmJy@wDcB{Hi@gCqAaGGWMk@WmAi@iCe@eCk@wDIm@_@eCOcA}@eG}@_Gi@oDg@gD}@cGg@kDk@kDq@cEu@{Dm@kCc@kBo@kCQo@y@_DkCwIoBiGcCaIi@cB]kAwAqEc@yAk@iBaA_DyCsJ_@iAkD}KSs@mCuI]iASs@o@aCa@iBCK]}Ay@qEi@gD]oCWgCKeAo@yHC]KiAc@iFM_CEu@MsCEoAAIAc@CkAC_CAuB@sC@iC@GHuDJsC@QHuAHyA@KNwBHkA\\oEZuEZiEd@aGhA}Od@oGr@qKb@eGTqCjAmPjAaPfAkO^}ElAuPRkCv@uKnA{PjA_PFaAH_A^oFbAkNnAcQX{DPeCHmADuA@iAAyACqACWE}@O{A[uCsAsK[aCu@oG{AwLCYKw@qAoK[eC[kCCQmA}J_AuHa@eDa@{CUgAG]Ia@e@gBGUY_Ae@sAe@gAi@iAg@_Ai@}@kF{Ha@k@oDgFgBiCoEsGeBgC}DyFmF{H_IgLsF_IeHeK}A}BkAcBqAmBqEsGsAoBw@gAeBeC}@qA{AwBGKcE_GiDaFU[wAuBW_@]g@a@g@]c@o@o@m@m@i@a@i@a@uB}AeCiByAgA}@o@y@m@AA{BaBq@g@[Uw@k@q@m@][IImAsAyAyAGG_BaBmCoCgDiDCC{CaDm@m@a@[c@YkAo@WM[K]Kc@Om@Kg@EYAA?SAk@@S?W@e@Bq@J_@FiAP}Dn@eC^cDh@g@J]Ha@Je@PsAh@sAj@g@ToAh@w@Zw@ZcBx@w@\\k@Xe@Zs@h@q@h@kA`Ae@`@s@t@QVSZYb@GLWb@Sd@c@nAM`@s@zBUp@o@rB_EfMQf@yBbHgBvFq@|Bs@zBu@zB_@lAQr@YtAu@tD{A`IgCnM]bBYvAu@xDc@rBk@lBk@xAs@|AgCrFGNcDdHEHUf@i@lA]t@g@bA_@n@k@v@o@p@qAhA}BnBg@b@kDxCSNsCdCk@`@a@XOHSJe@Ru@Vc@JsARsBV{@LsC^eARw@V]NSHu@\\e@Xi@`@q@j@w@t@QPyAxAaC`Cs@t@e@n@A@g@r@c@x@s@zA}@nBe@dA_BnDaBrDi@lA[r@}@pBcAvBILQZCFCBGLGJEDIJIJOLa@ZuBrAQHmCpAq@Zk@Py@Rk@LQDgHxAMBiCj@eF`AeDt@YDC@CBCBGDQBm@HKDC@mCl@QDSDIBK@MBa@J_ALcGnAmGnAsAXcKnBmCj@w@RcB`@g@NsExAgA^cBh@oA^}@TwAb@UHeA`@e@Ta@RkAr@MJ_@X[V[X[\\[^_@j@S\\Yf@S^w@xAi@fA}@dBgA|BiAxBe@z@Ud@MTS`@s@xAeArB{@dBk@fAi@~@{@xAWb@sAtB}AbCmAjBYd@q@dAaAxAeBnCQZcBhC{AzByB~CsAlBEFoA`BA@oBnCmAbBaAxA}@pAm@`AMRIN]r@KTEL[|@[bA]fAo@zBq@fCc@|Ag@`Bi@`BWx@Wv@Yr@MTOXYj@Y`@]f@c@f@EF{@fAkAtAy@fA_@b@OPs@x@o@v@q@z@S\\MTIL_@t@c@`A_AxBEJYx@a@`A_AhBi@t@m@p@SVKJw@x@wAfBW\\Yb@]l@ABGLOVWj@Qj@Qj@Qx@a@nBIb@EPCHUbASv@YbAW|@GNOf@Yp@s@nA_@f@m@|@q@|@MRq@~@U\\c@d@c@d@c@`@YRKHEB]TwAdA_Ap@oAx@GFIFSNWTm@h@q@p@SRQRGHMPU`@O\\MZKd@Or@Kn@Gb@Ef@Gl@Ch@GdDEtAAZCxACzBCp@Ab@E\\Gd@If@Mh@St@Yx@KXENKVM\\]bAYt@y@tB]fAc@hA_@`As@fBGPGNM`@Yx@[v@Yt@Ur@Wv@WfAYhAMh@Qv@O|@Kt@Kv@Ib@C`@En@G|@KpBOdCKxAIrAC^_@zGUnBQl@Q`@MPMNIFGDEBA@KFIBg@LUFcFpAaGbBaAXmDbA{Ab@uFxBkFpBmGdCcE~Ag@RiFzBiFxBcGfCGBiDhAqHfCiCz@sItCcA\\aDfA}Bx@iAf@_@PYTi@d@cAz@e@XuAz@m@^yA|@iAt@_@VUPSPUTOPc@j@e@p@c@r@oApBS^sAvBaAfBGLu@zAcAxBw@lBm@zAYn@u@dBWd@eAhBu@tAc@x@MZMXe@z@OVQPa@XI@E@K?UEy@Ua@IK?QAG@C?GDC@EDEDCBCHCLALAR@R^zCFn@Fd@?XCVI\\IRQXYTmAf@yAb@a@NKFGDMPKVSbAIXEPKVOVq@x@e@j@m@j@q@j@UT[^m@x@UVURWROF]NWJg@Ja@D[Ae@GOAQAq@@E@eBHg@FUHKFGDKPGLMh@Ef@A\\Bn@@HHt@Bz@?ZEZIZOVMNSL]HE@sACQ?Y@oBEWAG@K@GBC??@A?AB?@A@?@?B?B@F@@@DDDHBF@RBf@Cv@@rAL|@NTJf@NnAh@DBBBBB@@@D@B?F?B?BABA@?@A@E?A@E?GAE?YOUMQIe@Os@K}@?y@?i@@_@BK@ODUJQPKNMTGXAJE^CV@ZN`AVz@XjADT@PC^GZIPCFQNc@Ts@RA?aDx@}@Xi@Xe@b@g@\\SLYHk@Hg@CQ@E@A?EBA@ABAB?B?B?@BF?@DBDDD@\\FH@L?LALAJCLCpAa@r@QvAW`Ag@xAg@vAWdAIt@SJCFCHAFAB?@?DBD@BB@B@D@B?B?@AB?@ADA@A@IFSDC@o@Hk@Hu@Ls@TeA\\cAj@qAv@gClA[Rc@RYFm@Ak@@G@G@GBEDMNCFCFALEr@CVETIXINOXg@b@SPcBpAg@ZWTEF]f@}@xAm@`Aa@b@MFSFO@UCYM_@WUMa@IMC[AO@UBUHQHGDEDGHAFCNGXKx@QxAIb@Mh@Q`@Yd@]\\e@TYHYDcAFiABe@?[A_@IsBq@eAa@GCwAs@i@YKEG?E?E@A@A@?@ADAD?B@B@F@FBDFDHDpC`Bv@`@n@^jAn@h@Zl@Rh@JnAFdADn@B\\?d@IhDaAhBk@fAWn@Q^SZ[|@mAR[JK@AHGBADAD?B@DBB@@@@B@@?B?B?FABADi@lAa@`AKXm@dBu@rB}@~BOXKJSP_@NoANsC@gBDeAAqAK_BSWEiB][G_C_@cAGW?S@G?G@i@DuAXo@Jc@Hc@HWDo@L{@Bu@COAgEEY@yAZeBb@yH|A]HE@aBXaADq@?IAqBDkACa@E_@Gu@U{@Yg@UkAi@AASKSIMEIGm@_@YOOG_@OECo@Q[I_Ci@KCgBc@_EcAoA_@i@IUEsAEW?o@A]BaA@gABuD@uCHiBPg@FS@_@DIBg@Fw@Lc@F]FkANcANA?{@Di@Kc@YA?c@i@KSA?Sc@O]e@uAOo@Mm@EaAE_DCkDEmCEaAEeAGeACi@MeAOgAUaAYcAe@_Au@sB_@eBKiAGcBCuBGoCCq@Ks@S_Au@gCg@cBy@eCm@oAk@}@s@cAmCgBoAq@o@Mc@?K?w@BiARmAT}Dj@q@FmBPaBTsD|@c@FaANq@NWFi@Lq@XOHA@a@Rg@LeBAg@JYJC@UHo@J]HYDe@Pq@h@QFC@qAh@oA^kALi@K[EmASSEGB[FMD[JiA~@WRCBY?O@y@WGAk@Sg@{@Uo@q@kBEQa@o@}@w@"
//        ]
//        
//        for path in paths {
//            let path = GMSPath(fromEncodedPath: path)
//            let polyline = GMSPolyline(path: path)
//            polyline.strokeColor = .white
//            polyline.strokeWidth = 2.0
//            polyline.map = mapView
//        }
                
        /*let overviewPolylinePoint = "s`htFskunGeNwP}CeEKiAbC{I~AgEaCoCoDkEmEcGV_BP}CFqFREVWUkBo@aLgBuD{@wFgBmFgDkEcDmEkAeD@mIjBqQFsMkAiI}CuIaOwTsWsZyXcXoIgFeVsIgMyC{Gh@mARyC`@aD`@gJlAgLdBiJpDqW|M{G|@{MYwFcAqG_EmP}PoFkHkWqr@e`@wbA{CeHsEkGaDkCmUgRcJuLcOiXgEeFgIyFqJcDwIu@kQPqPN}Ko@sTqEkWcKq\\qSshAmr@_wAw|@cYcSaV_TuZkXcReNcHeC_DKaObAch@~Ng{@tMgEfA{NdB}\\xFuFwAqD{E_BmJoCuJuFkD_HY}B]uCgB_DaIU}Ls@aFcCsE_HqCeK{BcBaA}BaDcLmZsCcDmDqAgEJ_I~AoEMiDgA}g@_[{TcO{OgPs]s_@ef@kh@kYu[cQeRaYc`@gf@at@gWu_@wN_TmIiI{XwNan@kZ{WsMiZ_Po}@yn@s\\cVeP}MiJwQyTkg@_Wej@kbAelB_h@e~@}o@ifAiTc^_T_b@u`@yw@q\\m{@}^kbAic@crB}VwlAeIyi@oIkc@qg@yaBkFcWsDib@g@iSp@qXtRsmCfJepAnEyt@_F_e@gI{p@yE}ZoCeH_JeNmp@k`Ae^gh@uSiZeKsJcPqLaLwKuM_N_EsCgFiAmHj@iUvEcOtGcI`HgEdK_Rjl@yL~j@_DrNoFzL{JfSgT`RkBbAaHnAmIxAmCpA{MvMgLdVkF`LqEtD}FhC_L`CiQvDw^rHmTpEgLrDuMbFqE~EeKbSeXbe@a^ph@eM|_@oPpToHxOmHfJaGdT}G`LkEbEsIpGaDpEiArMc@`NaK~YkDlKoB|KcBnYgApEe@`@}RrFom@hUsn@fUiKzDmDpCgK`HwJtOsQ~^}@\\}Be@y@Vd@~HWbBsEzBcAn@o@fCeGbHqBxBmBn@cHDqA^g@pB@|GoA~@eC?iD@?Z`F`@zEbB?`@mA[iDe@oCFcAr@]zAbAdIg@dA{FbBuDtBaC\\e@Tr@b@rE}@zMeDf@f@iFhAcJnEgCl@_Bn@QnBkAfBwDtCoCjEsAt@eBw@aDNcAxFwAnC}Cl@kDGyGkCmAWLn@pMtGbFP`KoCtEaE`@HmAjDmDrJoAfAqKTsHcAeIe@gKlAkITcMlC_F\\_GK}GmCsEoBwSkEeTd@gGx@mEd@sBoA{BkIu@wWeBmGiBgK[kJkDqLyAmCaEkDoD_AcYfE}GbBwEj@cBb@gI~C_FWeAJaCbBkBWsAoAgA{CiB}Bc@Ic@vAG|Cp@nL"*/
        
//        if let overviewPolylinePath = GMSPath(fromEncodedPath: overviewPolylinePoint) {
//            let bounds = GMSCoordinateBounds(path: overviewPolylinePath)
//            let insets = UIEdgeInsets(top: 20, left: 40, bottom: 20, right: 40)
//            let camera = GMSCameraUpdate.fit(bounds, with: insets)
//            mapView.animate(with: camera)
//        }
    }
    
    func makeCoordinator() -> GoogleMapCoordinator {
        return GoogleMapCoordinator(self)
    }
}

extension GoogleMapViewRepresentable {

    class GoogleMapCoordinator: NSObject, GMSMapViewDelegate {

        var parent: GoogleMapViewRepresentable

        init(_ parent: GoogleMapViewRepresentable) {
            self.parent = parent
        }

        // MARK: - MKMapViewDelegate
        
        func mapViewSnapshotReady(_ mapView: GMSMapView) {
            // Log.info("mapViewSnapshotReady")
        }
        
        func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
            // Log.info("willMove gesture \(gesture)")
            self.parent.mapViewWillMove(gesture)
        }
        
        func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
            // Log.info("didChange position \(position)")
        }
        
        func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
            // Log.info("idleAt position \(position.target)")
            self.parent.mapViewIdleAtPosition(position)
        }

        func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
            // Log.info("didTapAt coordinate \(coordinate)")
        }
        
        func mapView(_ mapView: GMSMapView, didTapMyLocation location: CLLocationCoordinate2D) {
            // Log.info("didTapMyLocation")
        }
    }
}
