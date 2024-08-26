# Output the EKS Cluster endpoint
output "eks_cluster_endpoint" {
  description = "The endpoint of the EKS cluster"
  value       = aws_eks_cluster.Cluster.endpoint
}