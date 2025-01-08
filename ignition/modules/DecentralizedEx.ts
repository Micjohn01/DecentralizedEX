import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const MicjohnModule = buildModule("MicjohnModule", (m) => {

    const exchange = m.contract("Exchange");

    return { exchange };
});

export default MicjohnModule;