pragma solidity ^0.5.16;

// Internal references
import "./interfaces/IFlexibleStorage.sol";

// Libraries
import "./SafeDecimalMath.sol";

library SystemSettingsLib {
    using SafeMath for uint;
    using SafeDecimalMath for uint;

    // No more synths may be issued than the value of SNX backing them.
    uint public constant MAX_ISSUANCE_RATIO = 1e18;

    // The fee period must be between 1 day and 60 days.
    uint public constant MIN_FEE_PERIOD_DURATION = 1 days;
    uint public constant MAX_FEE_PERIOD_DURATION = 60 days;

    uint public constant MAX_TARGET_THRESHOLD = 50;

    uint public constant MAX_LIQUIDATION_RATIO = 1e18; // 100% issuance ratio
    uint public constant RATIO_FROM_TARGET_BUFFER = 2e18; // 200% - mininimum buffer between issuance ratio and liquidation ratio

    uint public constant MAX_LIQUIDATION_PENALTY = 1e18 / 4; // Max 25% liquidation penalty / bonus

    uint public constant MAX_LIQUIDATION_DELAY = 30 days;
    uint public constant MIN_LIQUIDATION_DELAY = 1 days;

    // Exchange fee may not exceed 10%.
    uint public constant MAX_EXCHANGE_FEE_RATE = 1e18 / 10;

    // Minimum Stake time may not exceed 1 weeks.
    uint public constant MAX_MINIMUM_STAKE_TIME = 1 weeks;

    uint public constant MAX_CROSS_DOMAIN_GAS_LIMIT = 8e6;
    uint public constant MIN_CROSS_DOMAIN_GAS_LIMIT = 3e6;

    int public constant MAX_WRAPPER_MINT_FEE_RATE = 1e18;

    int public constant MAX_WRAPPER_BURN_FEE_RATE = 1e18;

    // Atomic block volume limit is encoded as uint192.
    uint public constant MAX_ATOMIC_VOLUME_PER_BLOCK = uint192(-1);

    // TWAP window must be between 1 min and 1 day.
    uint public constant MIN_ATOMIC_TWAP_WINDOW = 60;
    uint public constant MAX_ATOMIC_TWAP_WINDOW = 86400;

    // Volatility consideration window must be between 1 min and 1 day.
    uint public constant MIN_ATOMIC_VOLATILITY_CONSIDERATION_WINDOW = 60;
    uint public constant MAX_ATOMIC_VOLATILITY_CONSIDERATION_WINDOW = 86400;

    function setUIntValue(
        address flexibleStorage,
        bytes32 settingContractName,
        bytes32 settingName,
        uint value
    ) internal {
        IFlexibleStorage(flexibleStorage).setUIntValue(settingContractName, settingName, value);
    }

    function setIntValue(
        address flexibleStorage,
        bytes32 settingContractName,
        bytes32 settingName,
        int value
    ) internal {
        IFlexibleStorage(flexibleStorage).setIntValue(settingContractName, settingName, value);
    }

    function setBoolValue(
        address flexibleStorage,
        bytes32 settingContractName,
        bytes32 settingName,
        bool value
    ) internal {
        IFlexibleStorage(flexibleStorage).setBoolValue(settingContractName, settingName, value);
    }

    function setAddressValue(
        address flexibleStorage,
        bytes32 settingContractName,
        bytes32 settingName,
        address value
    ) internal {
        IFlexibleStorage(flexibleStorage).setAddressValue(settingContractName, settingName, value);
    }

    function setCrossDomainMessageGasLimit(
        address flexibleStorage,
        bytes32 settingContractName,
        bytes32 gasLimitSettings,
        uint crossDomainMessageGasLimit
    ) external {
        require(
            crossDomainMessageGasLimit >= MIN_CROSS_DOMAIN_GAS_LIMIT &&
                crossDomainMessageGasLimit <= MAX_CROSS_DOMAIN_GAS_LIMIT,
            "Out of range xDomain gasLimit"
        );
        setUIntValue(flexibleStorage, settingContractName, gasLimitSettings, crossDomainMessageGasLimit);
    }

    function setIssuanceRatio(
        address flexibleStorage,
        bytes32 settingContractName,
        bytes32 settingName,
        uint _issuanceRatio
    ) external {
        require(_issuanceRatio <= MAX_ISSUANCE_RATIO, "New issuance ratio cannot exceed MAX_ISSUANCE_RATIO");
        setUIntValue(flexibleStorage, settingContractName, settingName, _issuanceRatio);
        // slither-disable-next-line reentrancy-events
        emit IssuanceRatioUpdated(_issuanceRatio);
    }

    function setTradingRewardsEnabled(
        address flexibleStorage,
        bytes32 settingContractName,
        bytes32 settingName,
        bool _tradingRewardsEnabled
    ) external {
        setBoolValue(flexibleStorage, settingContractName, settingName, _tradingRewardsEnabled);
        // slither-disable-next-line reentrancy-events
        emit TradingRewardsEnabled(_tradingRewardsEnabled);
    }

    function setWaitingPeriodSecs(
        address flexibleStorage,
        bytes32 settingContractName,
        bytes32 settingName,
        uint _waitingPeriodSecs
    ) external {
        setUIntValue(flexibleStorage, settingContractName, settingName, _waitingPeriodSecs);
        // slither-disable-next-line reentrancy-events
        emit WaitingPeriodSecsUpdated(_waitingPeriodSecs);
    }

    function setPriceDeviationThresholdFactor(
        address flexibleStorage,
        bytes32 settingContractName,
        bytes32 settingName,
        uint _priceDeviationThresholdFactor
    ) external {
        setUIntValue(flexibleStorage, settingContractName, settingName, _priceDeviationThresholdFactor);
        // slither-disable-next-line reentrancy-events
        emit PriceDeviationThresholdUpdated(_priceDeviationThresholdFactor);
    }

    function setFeePeriodDuration(
        address flexibleStorage,
        bytes32 settingContractName,
        bytes32 settingName,
        uint _feePeriodDuration
    ) external {
        require(_feePeriodDuration >= MIN_FEE_PERIOD_DURATION, "value < MIN_FEE_PERIOD_DURATION");
        require(_feePeriodDuration <= MAX_FEE_PERIOD_DURATION, "value > MAX_FEE_PERIOD_DURATION");

        setUIntValue(flexibleStorage, settingContractName, settingName, _feePeriodDuration);
        // slither-disable-next-line reentrancy-events
        emit FeePeriodDurationUpdated(_feePeriodDuration);
    }

    function setTargetThreshold(
        address flexibleStorage,
        bytes32 settingContractName,
        bytes32 settingName,
        uint _percent
    ) external {
        require(_percent <= MAX_TARGET_THRESHOLD, "Threshold too high");
        uint _targetThreshold = _percent.mul(SafeDecimalMath.unit()).div(100);

        setUIntValue(flexibleStorage, settingContractName, settingName, _targetThreshold);
        // slither-disable-next-line reentrancy-events
        emit TargetThresholdUpdated(_targetThreshold);
    }

    function setLiquidationDelay(
        address flexibleStorage,
        bytes32 settingContractName,
        bytes32 settingName,
        uint time
    ) external {
        require(time <= MAX_LIQUIDATION_DELAY, "Must be less than 30 days");
        require(time >= MIN_LIQUIDATION_DELAY, "Must be greater than 1 day");

        setUIntValue(flexibleStorage, settingContractName, settingName, time);
        // slither-disable-next-line reentrancy-events
        emit LiquidationDelayUpdated(time);
    }

    function setLiquidationRatio(
        address flexibleStorage,
        bytes32 settingContractName,
        bytes32 settingName,
        uint _liquidationRatio,
        uint getLiquidationPenalty,
        uint getIssuanceRatio
    ) external {
        require(
            _liquidationRatio <= MAX_LIQUIDATION_RATIO.divideDecimal(SafeDecimalMath.unit().add(getLiquidationPenalty)),
            "liquidationRatio > MAX_LIQUIDATION_RATIO / (1 + penalty)"
        );

        // MIN_LIQUIDATION_RATIO is a product of target issuance ratio * RATIO_FROM_TARGET_BUFFER
        // Ensures that liquidation ratio is set so that there is a buffer between the issuance ratio and liquidation ratio.
        uint MIN_LIQUIDATION_RATIO = getIssuanceRatio.multiplyDecimal(RATIO_FROM_TARGET_BUFFER);
        require(_liquidationRatio >= MIN_LIQUIDATION_RATIO, "liquidationRatio < MIN_LIQUIDATION_RATIO");

        setUIntValue(flexibleStorage, settingContractName, settingName, _liquidationRatio);
        // slither-disable-next-line reentrancy-events
        emit LiquidationRatioUpdated(_liquidationRatio);
    }

    function setLiquidationPenalty(
        address flexibleStorage,
        bytes32 settingContractName,
        bytes32 settingName,
        uint penalty
    ) external {
        require(penalty <= MAX_LIQUIDATION_PENALTY, "penalty > MAX_LIQUIDATION_PENALTY");

        setUIntValue(flexibleStorage, settingContractName, settingName, penalty);
        // slither-disable-next-line reentrancy-events
        emit LiquidationPenaltyUpdated(penalty);
    }

    function setRateStalePeriod(
        address flexibleStorage,
        bytes32 settingContractName,
        bytes32 settingName,
        uint period
    ) external {
        setUIntValue(flexibleStorage, settingContractName, settingName, period);
        // slither-disable-next-line reentrancy-events
        emit RateStalePeriodUpdated(period);
    }

    function setExchangeFeeRateForSynths(
        address flexibleStorage,
        bytes32 settingContractName,
        bytes32 settingExchangeFeeRate,
        bytes32[] calldata synthKeys,
        uint256[] calldata exchangeFeeRates
    ) external {
        require(synthKeys.length == exchangeFeeRates.length, "Array lengths dont match");
        for (uint i = 0; i < synthKeys.length; i++) {
            require(exchangeFeeRates[i] <= MAX_EXCHANGE_FEE_RATE, "MAX_EXCHANGE_FEE_RATE exceeded");
            setUIntValue(
                flexibleStorage,
                settingContractName,
                keccak256(abi.encodePacked(settingExchangeFeeRate, synthKeys[i])),
                exchangeFeeRates[i]
            );
            // slither-disable-next-line reentrancy-events
            emit ExchangeFeeUpdated(synthKeys[i], exchangeFeeRates[i]);
        }
    }

    function setMinimumStakeTime(
        address flexibleStorage,
        bytes32 settingContractName,
        bytes32 settingName,
        uint _seconds
    ) external {
        require(_seconds <= MAX_MINIMUM_STAKE_TIME, "stake time exceed maximum 1 week");
        setUIntValue(flexibleStorage, settingContractName, settingName, _seconds);
        // slither-disable-next-line reentrancy-events
        emit MinimumStakeTimeUpdated(_seconds);
    }

    function setDebtSnapshotStaleTime(
        address flexibleStorage,
        bytes32 settingContractName,
        bytes32 settingName,
        uint _seconds
    ) external {
        setUIntValue(flexibleStorage, settingContractName, settingName, _seconds);
        // slither-disable-next-line reentrancy-events
        emit DebtSnapshotStaleTimeUpdated(_seconds);
    }

    function setAggregatorWarningFlags(
        address flexibleStorage,
        bytes32 settingContractName,
        bytes32 settingName,
        address _flags
    ) external {
        require(_flags != address(0), "Valid address must be given");
        setAddressValue(flexibleStorage, settingContractName, settingName, _flags);
        // slither-disable-next-line reentrancy-events
        emit AggregatorWarningFlagsUpdated(_flags);
    }

    function setEtherWrapperMaxETH(
        address flexibleStorage,
        bytes32 settingContractName,
        bytes32 settingName,
        uint _maxETH
    ) external {
        setUIntValue(flexibleStorage, settingContractName, settingName, _maxETH);
        // slither-disable-next-line reentrancy-events
        emit EtherWrapperMaxETHUpdated(_maxETH);
    }

    function setEtherWrapperMintFeeRate(
        address flexibleStorage,
        bytes32 settingContractName,
        bytes32 settingName,
        uint _rate
    ) external {
        require(_rate <= uint(MAX_WRAPPER_MINT_FEE_RATE), "rate > MAX_WRAPPER_MINT_FEE_RATE");
        setUIntValue(flexibleStorage, settingContractName, settingName, _rate);
        // slither-disable-next-line reentrancy-events
        emit EtherWrapperMintFeeRateUpdated(_rate);
    }

    function setEtherWrapperBurnFeeRate(
        address flexibleStorage,
        bytes32 settingContractName,
        bytes32 settingName,
        uint _rate
    ) external {
        require(_rate <= uint(MAX_WRAPPER_BURN_FEE_RATE), "rate > MAX_WRAPPER_BURN_FEE_RATE");
        setUIntValue(flexibleStorage, settingContractName, settingName, _rate);
        // slither-disable-next-line reentrancy-events
        emit EtherWrapperBurnFeeRateUpdated(_rate);
    }

    function setWrapperMaxTokenAmount(
        address flexibleStorage,
        bytes32 settingContractName,
        bytes32 settingName,
        address _wrapper,
        uint _maxTokenAmount
    ) external {
        setUIntValue(
            flexibleStorage,
            settingContractName,
            keccak256(abi.encodePacked(settingName, _wrapper)),
            _maxTokenAmount
        );
        // slither-disable-next-line reentrancy-events
        emit WrapperMaxTokenAmountUpdated(_wrapper, _maxTokenAmount);
    }

    function setWrapperMintFeeRate(
        address flexibleStorage,
        bytes32 settingContractName,
        bytes32 settingName,
        address _wrapper,
        int _rate,
        int getWrapperBurnFeeRate
    ) external {
        require(_rate <= MAX_WRAPPER_MINT_FEE_RATE, "rate > MAX_WRAPPER_MINT_FEE_RATE");
        require(_rate >= -MAX_WRAPPER_MINT_FEE_RATE, "rate < -MAX_WRAPPER_MINT_FEE_RATE");

        // if mint rate is negative, burn fee rate should be positive and at least equal in magnitude
        // otherwise risk of flash loan attack
        if (_rate < 0) {
            require(-_rate <= getWrapperBurnFeeRate, "-rate > wrapperBurnFeeRate");
        }

        setIntValue(flexibleStorage, settingContractName, keccak256(abi.encodePacked(settingName, _wrapper)), _rate);
        // slither-disable-next-line reentrancy-events
        emit WrapperMintFeeRateUpdated(_wrapper, _rate);
    }

    function setWrapperBurnFeeRate(
        address flexibleStorage,
        bytes32 settingContractName,
        bytes32 settingName,
        address _wrapper,
        int _rate,
        int getWrapperMintFeeRate
    ) external {
        require(_rate <= MAX_WRAPPER_BURN_FEE_RATE, "rate > MAX_WRAPPER_BURN_FEE_RATE");
        require(_rate >= -MAX_WRAPPER_BURN_FEE_RATE, "rate < -MAX_WRAPPER_BURN_FEE_RATE");

        // if burn rate is negative, burn fee rate should be negative and at least equal in magnitude
        // otherwise risk of flash loan attack
        if (_rate < 0) {
            require(-_rate <= getWrapperMintFeeRate, "-rate > wrapperMintFeeRate");
        }

        setIntValue(flexibleStorage, settingContractName, keccak256(abi.encodePacked(settingName, _wrapper)), _rate);
        // slither-disable-next-line reentrancy-events
        emit WrapperBurnFeeRateUpdated(_wrapper, _rate);
    }

    function setInteractionDelay(
        address flexibleStorage,
        bytes32 settingContractName,
        bytes32 settingName,
        address _collateral,
        uint _interactionDelay
    ) external {
        require(_interactionDelay <= SafeDecimalMath.unit() * 3600, "Max 1 hour");
        setUIntValue(
            flexibleStorage,
            settingContractName,
            keccak256(abi.encodePacked(settingName, _collateral)),
            _interactionDelay
        );
        // slither-disable-next-line reentrancy-events
        emit InteractionDelayUpdated(_interactionDelay);
    }

    function setCollapseFeeRate(
        address flexibleStorage,
        bytes32 settingContractName,
        bytes32 settingName,
        address _collateral,
        uint _collapseFeeRate
    ) external {
        setUIntValue(
            flexibleStorage,
            settingContractName,
            keccak256(abi.encodePacked(settingName, _collateral)),
            _collapseFeeRate
        );
        // slither-disable-next-line reentrancy-events
        emit CollapseFeeRateUpdated(_collapseFeeRate);
    }

    function setAtomicMaxVolumePerBlock(
        address flexibleStorage,
        bytes32 settingContractName,
        bytes32 settingName,
        uint _maxVolume
    ) external {
        require(_maxVolume <= MAX_ATOMIC_VOLUME_PER_BLOCK, "Atomic max volume exceed maximum uint192");
        setUIntValue(flexibleStorage, settingContractName, settingName, _maxVolume);
        // slither-disable-next-line reentrancy-events
        emit AtomicMaxVolumePerBlockUpdated(_maxVolume);
    }

    function setAtomicTwapWindow(
        address flexibleStorage,
        bytes32 settingContractName,
        bytes32 settingName,
        uint _window
    ) external {
        require(_window >= MIN_ATOMIC_TWAP_WINDOW, "Atomic twap window under minimum 1 min");
        require(_window <= MAX_ATOMIC_TWAP_WINDOW, "Atomic twap window exceed maximum 1 day");
        setUIntValue(flexibleStorage, settingContractName, settingName, _window);
        // slither-disable-next-line reentrancy-events
        emit AtomicTwapWindowUpdated(_window);
    }

    function setAtomicEquivalentForDexPricing(
        address flexibleStorage,
        bytes32 settingContractName,
        bytes32 settingName,
        bytes32 _currencyKey,
        address _equivalent
    ) external {
        require(_equivalent != address(0), "Atomic equivalent is 0 address");
        setAddressValue(
            flexibleStorage,
            settingContractName,
            keccak256(abi.encodePacked(settingName, _currencyKey)),
            _equivalent
        );
        // slither-disable-next-line reentrancy-events
        emit AtomicEquivalentForDexPricingUpdated(_currencyKey, _equivalent);
    }

    function setAtomicExchangeFeeRate(
        address flexibleStorage,
        bytes32 settingContractName,
        bytes32 settingName,
        bytes32 _currencyKey,
        uint _exchangeFeeRate
    ) external {
        require(_exchangeFeeRate <= MAX_EXCHANGE_FEE_RATE, "MAX_EXCHANGE_FEE_RATE exceeded");
        setUIntValue(
            flexibleStorage,
            settingContractName,
            keccak256(abi.encodePacked(settingName, _currencyKey)),
            _exchangeFeeRate
        );
        // slither-disable-next-line reentrancy-events
        emit AtomicExchangeFeeUpdated(_currencyKey, _exchangeFeeRate);
    }

    function setAtomicPriceBuffer(
        address flexibleStorage,
        bytes32 settingContractName,
        bytes32 settingName,
        bytes32 _currencyKey,
        uint _buffer
    ) external {
        setUIntValue(flexibleStorage, settingContractName, keccak256(abi.encodePacked(settingName, _currencyKey)), _buffer);
        // slither-disable-next-line reentrancy-events
        emit AtomicPriceBufferUpdated(_currencyKey, _buffer);
    }

    function setAtomicVolatilityConsiderationWindow(
        address flexibleStorage,
        bytes32 settingContractName,
        bytes32 settingName,
        bytes32 _currencyKey,
        uint _window
    ) external {
        if (_window != 0) {
            require(
                _window >= MIN_ATOMIC_VOLATILITY_CONSIDERATION_WINDOW,
                "Atomic volatility consideration window under minimum 1 min"
            );
            require(
                _window <= MAX_ATOMIC_VOLATILITY_CONSIDERATION_WINDOW,
                "Atomic volatility consideration window exceed maximum 1 day"
            );
        }
        setUIntValue(flexibleStorage, settingContractName, keccak256(abi.encodePacked(settingName, _currencyKey)), _window);
        // slither-disable-next-line reentrancy-events
        emit AtomicVolatilityConsiderationWindowUpdated(_currencyKey, _window);
    }

    function setAtomicVolatilityUpdateThreshold(
        address flexibleStorage,
        bytes32 settingContractName,
        bytes32 settingName,
        bytes32 _currencyKey,
        uint _threshold
    ) external {
        setUIntValue(
            flexibleStorage,
            settingContractName,
            keccak256(abi.encodePacked(settingName, _currencyKey)),
            _threshold
        );
        // slither-disable-next-line reentrancy-events
        emit AtomicVolatilityUpdateThresholdUpdated(_currencyKey, _threshold);
    }

    // ========== EVENTS ==========
    event IssuanceRatioUpdated(uint newRatio);
    event TradingRewardsEnabled(bool enabled);
    event WaitingPeriodSecsUpdated(uint waitingPeriodSecs);
    event PriceDeviationThresholdUpdated(uint threshold);
    event FeePeriodDurationUpdated(uint newFeePeriodDuration);
    event TargetThresholdUpdated(uint newTargetThreshold);
    event LiquidationDelayUpdated(uint newDelay);
    event LiquidationRatioUpdated(uint newRatio);
    event LiquidationPenaltyUpdated(uint newPenalty);
    event RateStalePeriodUpdated(uint rateStalePeriod);
    event ExchangeFeeUpdated(bytes32 synthKey, uint newExchangeFeeRate);
    event MinimumStakeTimeUpdated(uint minimumStakeTime);
    event DebtSnapshotStaleTimeUpdated(uint debtSnapshotStaleTime);
    event AggregatorWarningFlagsUpdated(address flags);
    event EtherWrapperMaxETHUpdated(uint maxETH);
    event EtherWrapperMintFeeRateUpdated(uint rate);
    event EtherWrapperBurnFeeRateUpdated(uint rate);
    event WrapperMaxTokenAmountUpdated(address wrapper, uint maxTokenAmount);
    event WrapperMintFeeRateUpdated(address wrapper, int rate);
    event WrapperBurnFeeRateUpdated(address wrapper, int rate);
    event InteractionDelayUpdated(uint interactionDelay);
    event CollapseFeeRateUpdated(uint collapseFeeRate);
    event AtomicMaxVolumePerBlockUpdated(uint newMaxVolume);
    event AtomicTwapWindowUpdated(uint newWindow);
    event AtomicEquivalentForDexPricingUpdated(bytes32 synthKey, address equivalent);
    event AtomicExchangeFeeUpdated(bytes32 synthKey, uint newExchangeFeeRate);
    event AtomicPriceBufferUpdated(bytes32 synthKey, uint newBuffer);
    event AtomicVolatilityConsiderationWindowUpdated(bytes32 synthKey, uint newVolatilityConsiderationWindow);
    event AtomicVolatilityUpdateThresholdUpdated(bytes32 synthKey, uint newVolatilityUpdateThreshold);
}