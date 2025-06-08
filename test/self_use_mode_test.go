package test

import (
	"testing"
	"one-api/setting/operation_setting"
)

func TestSelfUseModeEnabled(t *testing.T) {
	// 测试自用模式是否正确启用
	if !operation_setting.SelfUseModeEnabled {
		t.Error("自用模式应该被强制启用")
	}
}

func TestModelRatioInSelfUseMode(t *testing.T) {
	// 测试自用模式下的模型倍率
	ratio, ok := operation_setting.GetModelRatio("gpt-4")
	if !ok {
		t.Error("自用模式下应该返回有效的模型倍率")
	}
	if ratio != 1.0 {
		t.Errorf("自用模式下模型倍率应该为1.0，实际为%f", ratio)
	}
}

func TestCacheRatioInSelfUseMode(t *testing.T) {
	// 测试自用模式下的缓存倍率
	ratio, ok := operation_setting.GetCacheRatio("gpt-4")
	if !ok {
		t.Error("自用模式下应该返回有效的缓存倍率")
	}
	if ratio != 1.0 {
		t.Errorf("自用模式下缓存倍率应该为1.0，实际为%f", ratio)
	}
}

func TestCreateCacheRatioInSelfUseMode(t *testing.T) {
	// 测试自用模式下的缓存创建倍率
	ratio, ok := operation_setting.GetCreateCacheRatio("claude-3-sonnet-20240229")
	if !ok {
		t.Error("自用模式下应该返回有效的缓存创建倍率")
	}
	if ratio != 1.0 {
		t.Errorf("自用模式下缓存创建倍率应该为1.0，实际为%f", ratio)
	}
}
