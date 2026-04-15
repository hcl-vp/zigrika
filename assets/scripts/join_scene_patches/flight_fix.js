setTimeout(() => {
  const {
    CharacterGlideComponent,
  } = require("../NewWorld/Character/Common/Component/CharacterGlideComponent");
  CharacterGlideComponent.prototype.CheckSoarAllowed = function () {
    return [true, void 0];
  };
}, 200);
