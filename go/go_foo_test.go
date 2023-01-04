package t_test

import (
	"testing"
)

func TestFoo1(t *testing.T) {
	t.Run("AAAAA", func(t *testing.T) {
		t.Log("Sub log")
	})
}

func TestFoo2(t *testing.T) {
	// t.Error("foo2")
}
