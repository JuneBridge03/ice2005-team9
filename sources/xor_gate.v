// XOR 게이트 (게이트 레벨 모델링)
module xor_gate (a, b, out);
  input a, b;
  output out;
  assign out = a ^ b;

endmodule
