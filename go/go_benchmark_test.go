package t_test

import (
	"testing"
	"time"
)

func Benchmark1(b *testing.B) {
	b.Log(b)
	for i := 0; i < b.N; i++ {
		time.Sleep(1 * time.Millisecond)
	}
}
