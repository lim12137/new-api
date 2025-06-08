package relay

import (
	"github.com/gin-gonic/gin"
	"one-api/service"
	relaycommon "one-api/relay/common"
	"one-api/setting/operation_setting"
)

// 简化的价格辅助函数，用于自用模式
func ModelPriceHelper(c *gin.Context, info *relaycommon.RelayInfo, promptTokens int, maxTokens int) (service.SimplePriceData, error) {
	// 自用模式下返回简化的价格数据
	if operation_setting.SelfUseModeEnabled {
		return service.SimplePriceData{
			ModelPrice:             0,
			ModelRatio:             1.0,
			CompletionRatio:        1.0,
			CacheRatio:             1.0,
			CacheCreationRatio:     1.0,
			ImageRatio:             1.0,
			GroupRatio:             1.0,
			UsePrice:               false,
			ShouldPreConsumedQuota: promptTokens + maxTokens,
		}, nil
	}

	// 非自用模式下的默认值（实际上不会被使用）
	return service.SimplePriceData{
		ModelPrice:             0,
		ModelRatio:             1.0,
		CompletionRatio:        1.0,
		CacheRatio:             1.0,
		CacheCreationRatio:     1.0,
		ImageRatio:             1.0,
		GroupRatio:             1.0,
		UsePrice:               false,
		ShouldPreConsumedQuota: promptTokens + maxTokens,
	}, nil
}
