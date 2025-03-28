export VLLM_ATTENTION_BACKEND=XFORMERS

DATA_DIR=/home/ubuntu/o1-replication/CustomTinyZero/data/intergration
BASE_MODEL=Qwen/Qwen2.5-1.5B-Instruct
#BASE_MODEL=/home/ubuntu/o1-replication/CustomTinyZero/checkpoints/verl_intergration/llama3.2_3b_integration/actor/global_step_80
EXPERIMENT_NAME=llama3.2_1b_integration
PROJECT_NAME=verl_intergration

set -x




python3 -m verl.trainer.main_ppo \
    algorithm.adv_estimator=grpo \
    data.train_files=$DATA_DIR/integration_train.parquet \
    data.val_files=$DATA_DIR/integration_test.parquet \
    data.train_batch_size=8 \
    data.val_batch_size=1312 \
    data.max_prompt_length=512 \
    data.max_response_length=1024 \
    actor_rollout_ref.model.path=$BASE_MODEL \
    actor_rollout_ref.actor.optim.lr=1e-6 \
    actor_rollout_ref.model.use_remove_padding=True \
    actor_rollout_ref.actor.ppo_mini_batch_size=256 \
    actor_rollout_ref.actor.use_dynamic_bsz=True \
    actor_rollout_ref.actor.ppo_max_token_len_per_gpu=24000 \
    actor_rollout_ref.actor.use_kl_loss=True \
    actor_rollout_ref.actor.kl_loss_coef=0.001 \
    actor_rollout_ref.actor.kl_loss_type=low_var_kl \
    actor_rollout_ref.model.enable_gradient_checkpointing=True \
    actor_rollout_ref.actor.fsdp_config.param_offload=False \
    actor_rollout_ref.actor.fsdp_config.grad_offload=False \
    actor_rollout_ref.actor.fsdp_config.optimizer_offload=False \
    actor_rollout_ref.rollout.tensor_model_parallel_size=2 \
    actor_rollout_ref.rollout.name=vllm \
    actor_rollout_ref.rollout.gpu_memory_utilization=0.6 \
    actor_rollout_ref.rollout.n=5 \
    actor_rollout_ref.ref.fsdp_config.param_offload=True \
    algorithm.kl_ctrl.kl_coef=0.001 \
    trainer.critic_warmup=0 \
    trainer.logger=['console','wandb'] \
    trainer.project_name='verl_intergration' \
    trainer.experiment_name='llama3.2_3b_intergration_rl' \
    trainer.n_gpus_per_node=8 \
    trainer.nnodes=1 \
    trainer.save_freq=10 \
    trainer.test_freq=10 \
    trainer.default_hdfs_dir="/home/ubuntu/o1-replication/CustomTinyZero/checkpoints/$PROJECT_NAME/$EXPERIMENT_NAME" \
    trainer.default_local_dir="/home/ubuntu/o1-replication/CustomTinyZero/checkpoints/$PROJECT_NAME/$EXPERIMENT_NAME" \
    trainer.total_epochs=200 $@ 2>&1 | tee -a $LOG_FILE