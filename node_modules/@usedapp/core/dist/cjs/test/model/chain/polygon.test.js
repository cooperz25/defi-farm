"use strict";
exports.__esModule = true;
var chai_1 = require("chai");
var defaults_1 = require("./defaults");
var src_1 = require("../../../src");
describe('Polygon Chain', function () {
    it('getChainId', function () {
        chai_1.expect(src_1.Polygon.chainId).to.equal(137);
        chai_1.expect(src_1.Mumbai.chainId).to.equal(80001);
    });
    it('getChainName', function () {
        chai_1.expect(src_1.Polygon.chainName).to.eq('Polygon');
        chai_1.expect(src_1.Mumbai.chainName).to.eq('Mumbai');
    });
    it('isTestChain', function () {
        chai_1.expect(src_1.Polygon.isTestChain).to.be["false"];
        chai_1.expect(src_1.Mumbai.isTestChain).to.be["true"];
    });
    it('isLocalChain', function () {
        chai_1.expect(src_1.Polygon.isLocalChain).to.be["false"];
        chai_1.expect(src_1.Mumbai.isLocalChain).to.be["false"];
    });
    it('getExplorerAddressLink', function () {
        chai_1.expect(src_1.Polygon.getExplorerAddressLink(defaults_1.TEST_ADDRESS)).to.eq("https://polygonscan.com/address/" + defaults_1.TEST_ADDRESS);
        chai_1.expect(src_1.Mumbai.getExplorerAddressLink(defaults_1.TEST_ADDRESS)).to.eq("https://mumbai.polygonscan.com/address/" + defaults_1.TEST_ADDRESS);
    });
    it('getExplorerTransactionLink', function () {
        chai_1.expect(src_1.Polygon.getExplorerTransactionLink(defaults_1.TEST_TX)).to.eq("https://polygonscan.com/tx/" + defaults_1.TEST_TX);
        chai_1.expect(src_1.Mumbai.getExplorerTransactionLink(defaults_1.TEST_TX)).to.eq("https://mumbai.polygonscan.com/tx/" + defaults_1.TEST_TX);
    });
});
//# sourceMappingURL=polygon.test.js.map