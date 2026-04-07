const WaterMaskView =
  require("../Module/WaterMask/WaterMaskController").WaterMaskView;

const _vOo = WaterMaskView.vOo;
WaterMaskView.vOo = function () {
  _vOo();
  WaterMaskView.EOo();
};

WaterMaskView.EOo();
